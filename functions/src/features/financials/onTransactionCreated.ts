import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Cloud Function that triggers whenever a new financial transaction is created.
 * It automatically updates inventory and creates corresponding log entries.
 */
export const onTransactionCreated = onDocumentCreated(
  {region: "asia-east2", document: "/farms/{farmId}/transactions/{transactionId}"},
  async (event) => {
    const transactionData = event.data?.data();
    if (!transactionData) {
      logger.log("No data found for the new transaction. Exiting.");
      return;
    }

    const {farmId} = event.params;
    const farmRef = db.collection("farms").doc(farmId);

    // Get actor info for log entries
    const actorId = transactionData.createdBy || "system";
    const actorName = transactionData.createdByName || "System";

    logger.info(`New transaction [${event.params.transactionId}] created. Category: ${transactionData.category}`);

    try {
      // Use a switch statement to handle different transaction categories.
      switch (transactionData.category) {
        // --- CASE: INVENTORY PURCHASE ---
        case "Inventory Purchase": {
          const batch = db.batch();

          // 1. Update inventory quantities for each line item.
          for (const item of transactionData.lineItems) {
            const itemRef = farmRef.collection("inventory_items").doc(item.itemId);
            batch.update(itemRef, {
              quantity: admin.firestore.FieldValue.increment(item.quantityAdded as number),
            });
          }

          // 2. Create the INVENTORY_RESTOCK log.
          const logRef = farmRef.collection("logbook").doc();
          batch.set(logRef, {
            type: "inventoryRestock",
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            actorId: actorId,
            actorName: actorName,
            payload: {
              supplierName: transactionData.title.replace("Purchase from ", ""),
              totalAmount: transactionData.amount,
              items: transactionData.lineItems,
            },
          });

          await batch.commit();
          logger.info("Inventory Purchase processed: Stock updated and log created.");
          break;
        }

        // --- CASE: INVENTORY SALE ---
        case "Inventory Sale": {
          await db.runTransaction(async (tx) => {
            const itemRefsAndData = [];
            
            // --- READ PHASE ---
            // First, read all the inventory documents you need to update.
            for (const item of transactionData.lineItems) {
              const itemRef = farmRef.collection("inventory_items").doc(item.itemId);
              const itemDoc = await tx.get(itemRef);
              if (!itemDoc.exists) throw new Error(`Item ${item.itemName} not found.`);
              
              const currentQty = (itemDoc.data()?.quantity ?? 0) as number;
              const quantityToSell = (item.quantityUsed as number);
              const newQty = currentQty - quantityToSell;

              if (newQty < 0) {
                throw new Error(`Not enough stock for ${item.itemName}.`);
              }
              // Store the reference, new quantity, and original item data for the write phase.
              itemRefsAndData.push({ ref: itemRef, newQuantity: newQty });
            }

            // --- WRITE PHASE ---
            // Now that all reads are done, you can perform all your writes.

            // 2. Update all inventory items.
            for (const item of itemRefsAndData) {
              tx.update(item.ref, { quantity: item.newQuantity });
            }

            // 3. Create the SALE_LOG.
            const logRef = farmRef.collection("logbook").doc();
            tx.set(logRef, {
              type: "sale",
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
              actorId: actorId,
              actorName: actorName,
              payload: {
                customerName: transactionData.title.replace("Sale to ", ""),
                totalAmount: transactionData.amount,
                items: transactionData.lineItems,
              },
            });
          });
          logger.info("Inventory Sale processed: Stock updated and log created.");
          break;
        }
        
        default:
          logger.info(`Simple transaction [${transactionData.category}]. No further action needed.`);
          break;
      }
    } catch (error) {
      logger.error("Error processing transaction:", error);
      await event.data?.ref.update({error: (error as Error).message});
    }
  },
);