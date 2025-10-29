// lib/src/features/farm_os/financials/presentation/controllers/financials_controller.dart

import 'dart:async';
import 'package:liminetic/src/features/farm_os/financials/presentation/screens/add_transaction_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/financials/data/financials_repository.dart';
import 'package:liminetic/src/features/farm_os/financials/domain/financial_transaction_model.dart';

part 'financials_controller.g.dart';

// --- DATA PROVIDERS ---
// The 'financialsProvider' and 'financialSummaryProvider' remain here, unchanged.

/// A provider that supplies a real-time stream of all financial transactions.
@riverpod
Stream<List<FinancialTransaction>> financials(Ref ref) {
  final financialsRepo = ref.watch(financialsRepositoryProvider);
  final farmId = ref.watch(sessionProvider).value?.activeFarm?.id;
  if (farmId == null) return Stream.value([]);
  return financialsRepo.watchTransactions(farmId);
}

/// A data class to hold the calculated financial summary.
class FinancialSummary {
  final double totalSales;
  final double totalExpenses;
  final double grossProfit;

  FinancialSummary({
    this.totalSales = 0.0,
    this.totalExpenses = 0.0,
    this.grossProfit = 0.0,
  });
}

/// A derived provider that calculates the financial summary from the list of transactions.
///
/// The UI will watch this provider. It automatically recalculates whenever the
/// list of transactions changes.
@riverpod
FinancialSummary financialSummary(Ref ref) {
  // Watch the asynchronous state of the main financials provider.
  final financialsAsync = ref.watch(financialsProvider);

  // When data is available, perform the calculation.
  return financialsAsync.maybeWhen(
    data: (transactions) {
      double sales = 0.0;
      double expenses = 0.0;

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          sales += transaction.amount;
        } else {
          expenses += transaction.amount;
        }
      }
      return FinancialSummary(
        totalSales: sales,
        totalExpenses: expenses,
        grossProfit: sales - expenses,
      );
    },
    // Return a default empty summary during loading or error states.
    orElse: () => FinancialSummary(),
  );
}

// --- ACTION CONTROLLER ---

/// A controller for handling actions related to financial transactions.
@riverpod
class FinancialsController extends _$FinancialsController {
  @override
  FutureOr<void> build() {}

  /// Records a multi-item sale and guarantees to throw an error on failure.
  Future<void> recordSale({
    required String customerName,
    required double totalAmount,
    required List<TransactionLineItem> lineItems,
    String? notes,
  }) async {
    final repo = ref.read(financialsRepositoryProvider);
    final session = ref.read(sessionProvider).value;
    final farmId = session?.activeFarm?.id;
    final currentUser = session?.appUser;
    if (farmId == null || currentUser == null)
      throw Exception('No active session.');

    final transaction = FinancialTransaction(
      id: '',
      type: TransactionType.income,
      title: 'Sale to $customerName',
      category: 'Inventory Sale',
      amount: totalAmount,
      transactionDate: DateTime.now(),
      notes: notes,
    );

    final lineItemMaps = lineItems
        .map(
          (li) => {
            'itemId': li.item.id,
            'itemName': li.item.name,
            'quantityUsed': double.tryParse(li.quantityController.text) ?? 0.0,
            'price': double.tryParse(li.priceController.text) ?? 0.0,
          },
        )
        .toList();

    state = const AsyncLoading();

    // **THE FIX**: Await the guard and then check for an error.
    // 1. Let AsyncValue.guard handle the state update.
    state = await AsyncValue.guard(
      () => repo.recordSaleTransaction(
        farmId: farmId,
        transaction: transaction,
        lineItems: lineItemMaps,
        actorId: currentUser.uid,
        actorName: currentUser.username,
      ),
    );

    // 2. If the guard caught an error and updated the state, re-throw that error to the UI.
    if (state.hasError) {
      throw state.error!;
    }
  }

  /// Adds a financial transaction of any type. The Cloud Function handles side effects.
  Future<void> addTransaction({
    required String title,
    required TransactionType type,
    required String category,
    required double amount,
    String? notes,
    List<Map<String, dynamic>> lineItems = const [],
  }) async {
    final repo = ref.read(financialsRepositoryProvider);
    final session = ref.read(sessionProvider).value;
    final farmId = session?.activeFarm?.id;
    final currentUser = session?.appUser;
    if (farmId == null || currentUser == null)
      throw Exception('No active session.');

    final newTransaction = FinancialTransaction(
      id: '',
      title: title,
      type: type,
      category: category,
      amount: amount,
      transactionDate: DateTime.now(),
      notes: notes,
      lineItems: lineItems,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.addTransaction(farmId, newTransaction),
    );
    if (state.hasError) throw state.error!;
  }

  // Apply the same robust pattern to the purchase method.
  Future<void> recordInventoryPurchase({
    required String supplierName,
    required double totalAmount,
    required List<TransactionLineItem> lineItems,
    String? notes,
  }) async {
    final repo = ref.read(financialsRepositoryProvider);
    final session = ref.read(sessionProvider).value;
    final farmId = session?.activeFarm?.id;
    final currentUser = session?.appUser;
    if (farmId == null || currentUser == null)
      throw Exception('No active session.');

    final transaction = FinancialTransaction(
      id: '',
      type: TransactionType.expense,
      title: 'Purchase from $supplierName',
      category: 'Inventory Purchase',
      amount: totalAmount,
      transactionDate: DateTime.now(),
      notes: notes,
    );

    final lineItemMaps = lineItems
        .map(
          (li) => {
            'itemId': li.item.id,
            'itemName': li.item.name,
            'quantityAdded': double.tryParse(li.quantityController.text) ?? 0.0,
            'price': double.tryParse(li.priceController.text) ?? 0.0,
          },
        )
        .toList();

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.addInventoryPurchaseTransaction(
        farmId: farmId,
        transaction: transaction,
        lineItems: lineItemMaps,
        actorId: currentUser.uid,
        actorName: currentUser.username,
      ),
    );

    if (state.hasError) {
      throw state.error!;
    }
  }
}
