// lib/src/features/farm_os/inventory/presentation/screens/inventory_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/common_widgets/filter_chip_row.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/controllers/inventory_controller.dart';

/// The main screen for displaying a filterable and searchable list of inventory items.
class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});
  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(inventoryFilterProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final filteredInventory = ref.watch(filteredInventoryProvider);

    // Get current state for the universal filter.
    final currentCategory = ref.watch(inventoryFilterProvider).category;
    final categories = ['All', 'Feeds', 'Medicines', 'Supplies', 'Equipment'];

    return ResponsiveScaffold(
      title: 'Inventory',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/inventory/add-inventory-item'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search inventory...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          FilterChipRow(
            options: categories,
            selectedValue: currentCategory,
            onSelected: (category) {
              ref.read(inventoryFilterProvider.notifier).setCategory(category);
            },
          ),
          Expanded(
            child: inventoryAsync.when(
              data: (_) {
                if (filteredInventory.isEmpty) {
                  return const Center(
                    child: Text('No items match your search or filter.'),
                  );
                }
                // Using a RefreshIndicator for pull-to-refresh functionality.
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(inventoryProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredInventory.length,
                    itemBuilder: (context, index) =>
                        _InventoryListTile(item: filteredInventory[index]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom list tile widget that displays a single inventory item according to the mockup.
class _InventoryListTile extends StatelessWidget {
  final InventoryItem item;
  const _InventoryListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLowStock =
        item.quantity <= item.lowStockThreshold && item.quantity > 0;
    final isOutOfStock = item.quantity <= 0;

    // Determine the color of the status indicator dot.
    Color? indicatorColor;
    if (isLowStock) indicatorColor = Colors.orange;
    if (isOutOfStock) indicatorColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () => context.push('/inventory/${item.id}', extra: item),
        leading: indicatorColor != null
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              )
            : const SizedBox(width: 12), // Placeholder for consistent alignment
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item.category),
        trailing: Text(
          '${item.quantity.toStringAsFixed(1)} ${item.unit}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
