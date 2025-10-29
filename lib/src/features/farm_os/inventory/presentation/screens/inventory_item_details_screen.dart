// lib/src/features/farm_os/inventory/presentation/screens/inventory_item_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/controllers/inventory_controller.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/controllers/inventory_details_controller.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/controllers/logbook_controller.dart';

/// A screen that displays the details of a single inventory item and its usage history.
class InventoryItemDetailsScreen extends ConsumerWidget {
  final InventoryItem item;
  const InventoryItemDetailsScreen({super.key, required this.item});

  /// Shows the modal bottom sheet for logging item usage.
  void _showLogUsageDialog(BuildContext context, InventoryItem currentItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to resize with the keyboard
      backgroundColor: Colors.transparent,
      builder: (_) => LogUsageDialog(item: currentItem),
    );
  }

  /// Shows a confirmation dialog and triggers the delete action.
  void _deleteItem(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to permanently delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(inventoryControllerProvider.notifier)
            .deleteItem(item.id);
        if (context.mounted) context.pop();
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the main provider and filter for this specific item to get live updates
    // after logging usage.
    final itemAsync = ref.watch(
      inventoryProvider.select(
        (asyncValue) => asyncValue.whenData(
          (items) =>
              items.firstWhere((i) => i.id == item.id, orElse: () => item),
        ),
      ),
    );

    // 1. Watch the raw logbook stream to get the loading/error state for the whole log list.
    final usageHistoryAsync = ref.watch(rawLogbookStreamProvider);
    // 2. Watch the derived (synchronous) provider to get the filtered list of usage logs.
    final usageHistoryLogs = ref.watch(itemUsageHistoryProvider(item.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/inventory/${item.id}/edit', extra: item);
              } else if (value == 'delete') {
                _deleteItem(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: itemAsync.when(
        data: (currentItem) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Item Details Section ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentItem.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentItem.category,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current Stock:'),
                          Text(
                            '${currentItem.quantity.toStringAsFixed(1)} ${currentItem.unit}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Low Stock Threshold:'),
                          Text(
                            '${currentItem.lowStockThreshold.toStringAsFixed(1)} ${currentItem.unit}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            // --- Usage Log Section (Placeholder) ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Usage Log',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: usageHistoryAsync.when(
                data: (_) {
                  if (usageHistoryLogs.isEmpty) {
                    return const Center(
                      child: Text('No usage has been logged for this item.'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: usageHistoryLogs.length,
                    itemBuilder: (context, index) {
                      final log = usageHistoryLogs[index];
                      final payload = log.payload;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            '${payload['quantityUsed']} ${currentItem.unit} used',
                          ),
                          subtitle: Text(
                            'By ${log.actorName} on ${DateFormat.yMMMd().format(log.timestamp.toDate())}',
                          ),
                          trailing: Text(payload['notes'] ?? ''),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) =>
                    Center(child: Text('Error loading usage history: $e')),
              ),
            ),

            // --- Log Usage Button ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showLogUsageDialog(context, currentItem),
                icon: const Icon(Icons.remove),
                label: const Text('Log Usage'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

/// A modal bottom sheet dialog for logging the usage of an inventory item.
class LogUsageDialog extends ConsumerStatefulWidget {
  final InventoryItem item;
  const LogUsageDialog({super.key, required this.item});
  @override
  ConsumerState<LogUsageDialog> createState() => _LogUsageDialogState();
}

class _LogUsageDialogState extends ConsumerState<LogUsageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  /// Validates the form and calls the controller to log the usage.
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref
          .read(inventoryControllerProvider.notifier)
          .logItemUsage(
            itemId: widget.item.id,
            quantityUsed: double.parse(_quantityController.text),
            notes: _notesController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);
    // This padding ensures the modal moves up with the keyboard.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Draggable handle at the top of the modal.
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Log Usage',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity Used',
                  hintText: 'e.g. 2',
                  suffixText: widget.item.unit,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Quantity is required.';
                  final quantity = double.tryParse(value);
                  if (quantity == null) return 'Please enter a valid number.';
                  if (quantity <= 0) return 'Must be greater than 0.';
                  if (quantity > widget.item.quantity)
                    return 'Usage cannot exceed available stock (${widget.item.quantity}).';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g. For Pen #5',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
