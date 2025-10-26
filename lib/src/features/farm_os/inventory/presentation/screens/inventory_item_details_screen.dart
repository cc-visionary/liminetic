// lib/src/features/farm_os/inventory/presentation/screens/inventory_item_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/controllers/inventory_controller.dart';

/// A screen that displays the details of a single inventory item and its usage history.
class InventoryItemDetailsScreen extends ConsumerWidget {
  final InventoryItem item;
  const InventoryItemDetailsScreen({super.key, required this.item});

  /// Shows the modal bottom sheet for logging item usage.
  void _showLogUsageDialog(BuildContext context, InventoryItem currentItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
          'Are you sure you want to permanently delete "${item.name}"?',
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
    // Watch the main provider and filter for this specific item to get live updates.
    final itemAsync = ref
        .watch(inventoryProvider)
        .whenData(
          (items) =>
              items.firstWhere((i) => i.id == item.id, orElse: () => item),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/inventory/${item.id}/edit', extra: item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteItem(context, ref),
          ),
        ],
      ),
      body: itemAsync.when(
        data: (currentItem) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentItem.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentItem.category,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Stock:'),
                      Text(
                        '${currentItem.quantity.toStringAsFixed(1)} ${currentItem.unit}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            // TODO: Display a list of INVENTORY_USAGE logs related to this item.
            const Expanded(
              child: Center(child: Text('Usage history will be shown here.')),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showLogUsageDialog(context, currentItem),
                icon: const Icon(Icons.remove),
                label: const Text('Log Usage'),
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
    return Padding(
      // This padding ensures the modal moves up with the keyboard.
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
                  if (quantity > widget.item.quantity)
                    return 'Usage cannot exceed available stock.';
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
