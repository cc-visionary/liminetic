// lib/src/features/farm_os/financials/domain/financial_transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// An enum representing the type of financial transaction.
enum TransactionType { income, expense }

/// Represents a single financial transaction (income or expense) for a farm.
class FinancialTransaction {
  final String id;
  final String title;
  final TransactionType type;
  final String category; // e.g., "Feed Purchase", "Animal Sale", "Utilities"
  final double amount;
  final DateTime transactionDate;
  final String? notes;
  final List<Map<String, dynamic>> lineItems;

  FinancialTransaction({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
    required this.transactionDate,
    this.notes,
    this.lineItems = const [],
  });

  factory FinancialTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialTransaction(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: data['category'] ?? 'Uncategorized',
      amount: (data['amount'] ?? 0.0).toDouble(),
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      notes: data['notes'],
      lineItems: List<Map<String, dynamic>>.from(data['lineItems'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type.name, // Saves "income" or "expense" as a string
      'category': category,
      'amount': amount,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'notes': notes,
      'lineItems': lineItems,
    };
  }
}
