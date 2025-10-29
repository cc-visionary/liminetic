import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

const db = admin.firestore();

/**
 * Cloud Function that triggers when a task document is updated.
 * This uses the modern v2 syntax required by firebase-functions v5+.
 *
 * It checks if a task's status was changed to "completed" and, if so,
 * automatically deducts any linked inventory and creates a log entry.
 */
export const onTaskCompleted = onDocumentUpdated(
  {region: "asia-east2", document: "/farms/{farmId}/tasks/{taskId}"},
  async (event) => {
    // In v2 functions, the change data is nested inside `event.data`.
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    // Safety check to ensure we have data to compare.
    if (!beforeData || !afterData) {
      logger.log("Document data is missing, exiting function.");
      return;
    }

    // The core logic: Proceed only if the status changed FROM something else
    // TO "completed". This prevents the function from running on every minor edit.
    if (beforeData.status !== "completed" && afterData.status === "completed") {
      logger.info(`Task ${event.params.taskId} completed. Processing...`);

      const linkedInventory = afterData.linkedInventory as Array<{[key: string]: any}> | undefined;

      if (!linkedInventory || linkedInventory.length === 0) {
        logger.info("No linked inventory to process. Function finished.");
        return; // Exit if there's nothing to do.
      }

      const {farmId} = event.params;
      const farmRef = db.collection("farms").doc(farmId);

      // Use a Firestore Transaction for data integrity.
      try {
        await db.runTransaction(async (tx) => {
          // --- READ PHASE ---
          const itemPromises = linkedInventory.map(async (item) => {
            const itemRef = farmRef.collection("inventory_items").doc(item.itemId);
            const itemDoc = await tx.get(itemRef);
            return { itemRef, itemDoc, itemData: item };
          });
          const itemsToUpdate = await Promise.all(itemPromises);

          // --- WRITE PHASE ---
          for (const { itemRef, itemDoc, itemData } of itemsToUpdate) {
            if (!itemDoc.exists) throw new Error(`Item ${itemData.itemName} not found.`);
            
            const currentQty = (itemDoc.data()?.quantity ?? 0) as number;
            const newQty = currentQty - (itemData.quantityUsed as number);
            if (newQty < 0) throw new Error(`Not enough stock for ${itemData.itemName}.`);
            
            tx.update(itemRef, { quantity: newQty });

            const logRef = farmRef.collection("logbook").doc();
            tx.set(logRef, {
              type: "inventoryUsage",
              timestamp: FieldValue.serverTimestamp(),
              actorId: afterData.completedBy ?? "system",
              actorName: afterData.completedByName ?? "System",
              payload: {
                source: "Task Completion",
                taskTitle: afterData.title,
                // **THE FIX**: Put item details directly in the payload.
                itemName: itemData.itemName,
                quantityUsed: itemData.quantityUsed,
                itemId: itemData.itemId,
              },
            });
          }
        });
        logger.info("Inventory updated and logs created for task completion.");
      } catch (error) {
        logger.error("Error processing task completion:", error);
      }
    }
  },
);