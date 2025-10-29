// lib/src/features/farm_os/financials/presentation/screens/transaction_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/features/farm_os/financials/domain/financial_transaction_model.dart';

/// A screen that displays the full details of a single financial transaction.
class TransactionDetailsScreen extends ConsumerWidget {
  final FinancialTransaction transaction;
  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${transaction.category} • ${DateFormat.yMMMd().format(transaction.transactionDate)}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${isIncome ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
                        style: theme.textTheme.displaySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Line Items Section ---
            if (transaction.lineItems.isNotEmpty) ...[
              Text('Items', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: transaction.lineItems.map((item) {
                    final quantity = item['quantityUsed'] ?? item['quantityAdded'] ?? 0.0;
                    final price = item['price'] ?? 0.0;
                    final total = quantity * price;

                    return ListTile(
                      title: Text(item['itemName'] ?? 'Unknown Item'),
                      subtitle: Text('Qty: $quantity @ ${currencyFormat.format(price)}'),
                      trailing: Text(
                        currencyFormat.format(total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // --- Notes Section ---
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              Text('Notes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(transaction.notes!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}