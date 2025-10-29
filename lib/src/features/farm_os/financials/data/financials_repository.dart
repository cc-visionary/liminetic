// lib/src/features/farm_os/financials/data/financials_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/features/farm_os/financials/domain/financial_transaction_model.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';

/// Repository for managing financial transaction data in Firestore.
class FinancialsRepository {
  final FirebaseFirestore _firestore;
  FinancialsRepository(this._firestore);

  /// Gets a real-time stream of all financial transactions for a farm,
  /// ordered by date to show the most recent first.
  Stream<List<FinancialTransaction>> watchTransactions(String farmId) {
    return _firestore
        .collection('farms')
        .doc(farmId)
        .collection('transactions')
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FinancialTransaction.fromFirestore(doc))
              .toList(),
        );
  }

  /// Adds a new transaction document. The Cloud Function will handle the rest.
  Future<void> addTransaction(
    String farmId,
    FinancialTransaction transaction,
  ) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('transactions')
        .add(transaction.toMap());
  }

  /// Atomically records a multi-item inventory purchase.
  ///
  /// Uses a `WriteBatch` because it performs multiple "write" operations without
  /// needing to "read" data first. This is highly efficient for restocking.
  Future<void> addInventoryPurchaseTransaction({
    required String farmId,
    required FinancialTransaction transaction,
    required List<Map<String, dynamic>> lineItems,
    required String actorId,
    required String actorName,
  }) async {
    final batch = _firestore.batch();
    final farmRef = _firestore.collection('farms').doc(farmId);

    // 1. Create the main Expense transaction document.
    final transactionRef = farmRef.collection('transactions').doc();
    batch.set(transactionRef, transaction.toMap());

    // 2. For each line item, increment the inventory stock.
    for (final lineItem in lineItems) {
      final itemRef = farmRef
          .collection('inventory_items')
          .doc(lineItem['itemId']);
      batch.update(itemRef, {
        'quantity': FieldValue.increment(lineItem['quantityAdded'] as double),
      });
    }

    // 3. Create a single INVENTORY_RESTOCK log entry for this purchase.
    final logRef = farmRef.collection('logbook').doc();
    final restockLog = LogEntry(
      id: '',
      type: LogType.inventoryRestock,
      timestamp: Timestamp.now(),
      actorId: actorId,
      actorName: actorName,
      payload: {
        'supplierName': transaction.title.replaceFirst('Purchase from ', ''),
        'totalAmount': transaction.amount,
        'items': lineItems, // Store the list of items purchased.
      },
    );
    batch.set(logRef, restockLog.toMap());

    // 4. Commit all writes to the database in a single operation.
    await batch.commit();
  }

  /// Atomically records a multi-item sale.
  ///
  /// Uses a `Transaction` because we must "read" the current stock level
  /// before we "write" the new, decremented value. This is essential to
  /// prevent race conditions and overselling.
  Future<void> recordSaleTransaction({
    required String farmId,
    required FinancialTransaction transaction,
    required List<Map<String, dynamic>> lineItems,
    required String actorId,
    required String actorName,
  }) async {
    final farmRef = _firestore.collection('farms').doc(farmId);

    await _firestore.runTransaction((tx) async {
      // 1. Create the main Income transaction document.
      final transactionRef = farmRef.collection('transactions').doc();
      tx.set(transactionRef, transaction.toMap());

      // 2. For each line item, read, validate, and update the inventory stock.
      for (final lineItem in lineItems) {
        final itemRef = farmRef
            .collection('inventory_items')
            .doc(lineItem['itemId']);
        final itemSnapshot = await tx.get(itemRef);
        if (!itemSnapshot.exists) {
          throw Exception(
            "Item '${lineItem['itemName']}' not found in inventory.",
          );
        }

        final currentQuantity = (itemSnapshot.data()!['quantity'] as num)
            .toDouble();
        final quantityToSell = (lineItem['quantityUsed'] as double);
        final newQuantity = currentQuantity - quantityToSell;

        // This is the critical validation that will throw an error.
        if (newQuantity < 0) {
          throw Exception(
            "Not enough stock for '${lineItem['itemName']}'. "
            "Only $currentQuantity available, but tried to sell $quantityToSell.",
          );
        }

        tx.update(itemRef, {'quantity': newQuantity});
      }

      // 3. Create a single SALE_LOG entry.
      final logRef = farmRef.collection('logbook').doc();
      final saleLog = LogEntry(
        id: '',
        type: LogType.sale,
        timestamp: Timestamp.now(),
        actorId: actorId,
        actorName: actorName,
        payload: {
          'customerName': transaction.title.replaceFirst('Sale to ', ''),
          'totalAmount': transaction.amount,
          'items': lineItems,
        },
      );
      tx.set(logRef, saleLog.toMap());
    });
  }
}

/// Riverpod provider for the FinancialsRepository.
final financialsRepositoryProvider = Provider<FinancialsRepository>((ref) {
  return FinancialsRepository(FirebaseFirestore.instance);
});
