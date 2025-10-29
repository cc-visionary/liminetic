// lib/src/features/farm_os/financials/presentation/screens/financials_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/farm_os/financials/domain/financial_transaction_model.dart';
import 'package:liminetic/src/features/farm_os/financials/presentation/controllers/financials_controller.dart';

/// The main screen for displaying a financial overview and recent transactions.
class FinancialsScreen extends ConsumerWidget {
  const FinancialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financialsAsync = ref.watch(financialsProvider);
    final summary = ref.watch(financialSummaryProvider);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      title: 'Finances',
      floatingActionButton: null, // FAB is replaced by bottom buttons
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Summary Cards ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _StatCard(title: 'Total Sales', amount: summary.totalSales),
                const SizedBox(height: 12),
                _StatCard(
                  title: 'Total Expenses',
                  amount: summary.totalExpenses,
                ),
                const SizedBox(height: 12),
                _StatCard(
                  title: 'Gross Profit',
                  amount: summary.grossProfit,
                  isHighlighted: true,
                ),
              ],
            ),
          ),
          // --- Recent Transactions Header ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Recent Transactions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // --- Transactions List ---
          Expanded(
            child: financialsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('Log your first sale or expense.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(financialsProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) =>
                        _TransactionListTile(transaction: transactions[index]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          // --- Bottom Action Buttons ---
          _BottomActionButtons(),
        ],
      ),
    );
  }
}

/// A card for displaying a single financial statistic.
class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isHighlighted;

  const _StatCard({
    required this.title,
    required this.amount,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 0);
    final theme = Theme.of(context);
    return Card(
      color: isHighlighted
          ? theme.colorScheme.primary.withOpacity(0.2)
          : theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              currencyFormat.format(amount),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom list tile for displaying a recent transaction.
class _TransactionListTile extends StatelessWidget {
  const _TransactionListTile({required this.transaction});
  final FinancialTransaction transaction;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) return 'Today';
    if (transactionDate == yesterday) return 'Yesterday';
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.trending_up : Icons.trending_down;
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatDate(transaction.transactionDate)),
        trailing: Text(
          '${isIncome ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () =>
            context.push('/financials/${transaction.id}', extra: transaction),
      ),
    );
  }
}

/// The bottom row containing "Add Sale" and "Add Expense" buttons.
class _BottomActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                '/financials/add-transaction',
                extra: TransactionType.income,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Sale'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push(
                '/financials/add-transaction',
                extra: TransactionType.expense,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
