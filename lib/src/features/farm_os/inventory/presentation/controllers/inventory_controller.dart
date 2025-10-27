// lib/src/features/farm_os/inventory/presentation/controllers/inventory_controller.dart

import 'dart:async';
import 'package:liminetic/src/features/farm_os/logbook/data/logbook_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/inventory/data/inventory_repository.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';

part 'inventory_controller.g.dart';
// --- FILTERING LOGIC ---

/// A data class to hold the filter state for the inventory list.
class InventoryFilter {
  final String category;
  final String query;
  InventoryFilter({this.category = 'All', this.query = ''});
}

/// A Notifier to manage the state of the inventory filters.
@riverpod
class InventoryFilterNotifier extends _$InventoryFilterNotifier {
  @override
  InventoryFilter build() => InventoryFilter();

  void setCategory(String category) {
    state = InventoryFilter(category: category, query: state.query);
  }

  void setSearchQuery(String query) {
    state = InventoryFilter(
      category: state.category,
      query: query.toLowerCase(),
    );
  }
}

// --- DATA PROVIDERS ---

/// A provider that supplies a real-time stream of all inventory items.
@riverpod
Stream<List<InventoryItem>> inventory(Ref ref) {
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  final farmId = ref.watch(sessionProvider).value?.activeFarm?.id;
  if (farmId == null) return Stream.value([]);
  return inventoryRepo.watchInventory(farmId);
}

/// A derived provider that applies the current search and category filters to the inventory list.
@riverpod
List<InventoryItem> filteredInventory(Ref ref) {
  final inventoryAsync = ref.watch(inventoryProvider);
  final filter = ref.watch(inventoryFilterProvider);

  return inventoryAsync.maybeWhen(
    data: (items) {
      var filteredItems = items;

      if (filter.category != 'All') {
        filteredItems = filteredItems
            .where((item) => item.category == filter.category)
            .toList();
      }

      if (filter.query.isNotEmpty) {
        filteredItems = filteredItems
            .where((item) => item.name.toLowerCase().contains(filter.query))
            .toList();
      }
      return filteredItems;
    },
    orElse: () => [],
  );
}

/// A controller for handling actions related to inventory items (add, edit, delete).
@riverpod
class InventoryController extends _$InventoryController {
  @override
  FutureOr<void> build() {}

  Future<void> addItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required double lowStockThreshold,
  }) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm');

    final newItem = InventoryItem(
      id: '',
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      lowStockThreshold: lowStockThreshold,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.addItem(farmId, newItem));
  }

  Future<void> editItem({
    required String itemId,
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required double lowStockThreshold,
  }) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm');

    final updatedData = {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'lowStockThreshold': lowStockThreshold,
    };
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.updateItem(farmId, itemId, updatedData),
    );
  }

  Future<void> deleteItem(String itemId) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.deleteItem(farmId, itemId));
  }

  /// Logs the usage of an inventory item in an atomic transaction.
  Future<void> logItemUsage({
    required String itemId,
    required double quantityUsed,
    required String notes,
  }) async {
    final inventoryRepo = ref.read(inventoryRepositoryProvider);
    // We need the logbook repo to create a log entry inside the transaction.
    final logbookRepo = ref.read(logbookRepositoryProvider);
    final session = ref.read(sessionProvider).value;
    final farmId = session?.activeFarm?.id;
    final currentUser = session?.appUser;

    if (farmId == null || currentUser == null)
      throw Exception('No active session.');

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => inventoryRepo.logItemUsage(
        farmId: farmId,
        itemId: itemId,
        quantityUsed: quantityUsed,
        notes: notes,
        actorId: currentUser.uid,
        actorName: currentUser.username,
        logbookRepository: logbookRepo, // Pass the repo to the transaction
      ),
    );
  }
}
