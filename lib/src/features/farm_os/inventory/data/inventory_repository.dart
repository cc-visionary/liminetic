// lib/src/features/farm_os/inventory/data/inventory_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';
import 'package:liminetic/src/features/farm_os/logbook/data/logbook_repository.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';

/// Repository for managing inventory data in Firestore.
class InventoryRepository {
  final FirebaseFirestore _firestore;
  InventoryRepository(this._firestore);

  /// Gets a real-time stream of all inventory items for a specific farm.
  Stream<List<InventoryItem>> watchInventory(String farmId) {
    return _firestore
        .collection('farms')
        .doc(farmId)
        .collection('inventory_items')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryItem.fromFirestore(doc))
              .toList(),
        );
  }

  /// Adds a new inventory item document.
  Future<void> addItem(String farmId, InventoryItem item) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('inventory_items')
        .add(item.toMap());
  }

  /// Atomically logs item usage by updating inventory quantity and creating a log entry.
  Future<void> logItemUsage({
    required String farmId,
    required String itemId,
    required double quantityUsed,
    required String notes,
    required String actorId,
    required String actorName,
    required LogbookRepository
    logbookRepository, // Needed to access logbook collection
  }) async {
    final itemRef = _firestore
        .collection('farms')
        .doc(farmId)
        .collection('inventory_items')
        .doc(itemId);

    await _firestore.runTransaction((transaction) async {
      // 1. Read the current item data within the transaction.
      final itemSnapshot = await transaction.get(itemRef);
      if (!itemSnapshot.exists) {
        throw Exception("Inventory item could not be found.");
      }
      final currentItem = InventoryItem.fromFirestore(itemSnapshot);

      // 2. Validate and calculate the new quantity.
      final newQuantity = currentItem.quantity - quantityUsed;
      if (newQuantity < 0) {
        throw Exception("Not enough stock available to log this usage.");
      }

      // 3. Create the new log entry object.
      final newLog = LogEntry(
        id: '', // Firestore will generate
        type: LogType.inventoryUsage,
        timestamp: Timestamp.now(),
        actorId: actorId,
        actorName: actorName,
        payload: {
          'itemId': itemId,
          'itemName': currentItem.name,
          'quantityUsed': quantityUsed,
          'notes': notes,
        },
      );

      // 4. Perform the writes: update the item and create the log entry.
      transaction.update(itemRef, {'quantity': newQuantity});
      // We must create the log entry using a new document reference within the transaction.
      final logRef = _firestore
          .collection('farms')
          .doc(farmId)
          .collection('logbook')
          .doc();
      transaction.set(logRef, newLog.toMap());
    });
  }

  /// Updates an existing inventory item document.
  Future<void> updateItem(
    String farmId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('inventory_items')
        .doc(itemId)
        .update(data);
  }

  /// Deletes an inventory item document.
  Future<void> deleteItem(String farmId, String itemId) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('inventory_items')
        .doc(itemId)
        .delete();
  }
}

/// Riverpod provider for the InventoryRepository.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(FirebaseFirestore.instance);
});
