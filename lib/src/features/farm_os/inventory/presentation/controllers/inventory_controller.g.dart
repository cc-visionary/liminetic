// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A Notifier to manage the state of the inventory filters.

@ProviderFor(InventoryFilterNotifier)
const inventoryFilterProvider = InventoryFilterNotifierProvider._();

/// A Notifier to manage the state of the inventory filters.
final class InventoryFilterNotifierProvider
    extends $NotifierProvider<InventoryFilterNotifier, InventoryFilter> {
  /// A Notifier to manage the state of the inventory filters.
  const InventoryFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryFilterNotifierHash();

  @$internal
  @override
  InventoryFilterNotifier create() => InventoryFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryFilter>(value),
    );
  }
}

String _$inventoryFilterNotifierHash() =>
    r'a5314cd127aa9dedbb504ca065694c25af8a59bc';

/// A Notifier to manage the state of the inventory filters.

abstract class _$InventoryFilterNotifier extends $Notifier<InventoryFilter> {
  InventoryFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<InventoryFilter, InventoryFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InventoryFilter, InventoryFilter>,
              InventoryFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// A provider that supplies a real-time stream of all inventory items.

@ProviderFor(inventory)
const inventoryProvider = InventoryProvider._();

/// A provider that supplies a real-time stream of all inventory items.

final class InventoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryItem>>,
          List<InventoryItem>,
          Stream<List<InventoryItem>>
        >
    with
        $FutureModifier<List<InventoryItem>>,
        $StreamProvider<List<InventoryItem>> {
  /// A provider that supplies a real-time stream of all inventory items.
  const InventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryHash();

  @$internal
  @override
  $StreamProviderElement<List<InventoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InventoryItem>> create(Ref ref) {
    return inventory(ref);
  }
}

String _$inventoryHash() => r'efc22dc8f2f4251d41601aff0c7cc988555b3923';

/// A derived provider that applies the current search and category filters to the inventory list.

@ProviderFor(filteredInventory)
const filteredInventoryProvider = FilteredInventoryProvider._();

/// A derived provider that applies the current search and category filters to the inventory list.

final class FilteredInventoryProvider
    extends
        $FunctionalProvider<
          List<InventoryItem>,
          List<InventoryItem>,
          List<InventoryItem>
        >
    with $Provider<List<InventoryItem>> {
  /// A derived provider that applies the current search and category filters to the inventory list.
  const FilteredInventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredInventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredInventoryHash();

  @$internal
  @override
  $ProviderElement<List<InventoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<InventoryItem> create(Ref ref) {
    return filteredInventory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<InventoryItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<InventoryItem>>(value),
    );
  }
}

String _$filteredInventoryHash() => r'62945debb576c7adba040abf89eef9948e73d23d';

/// A controller for handling actions related to inventory items (add, edit, delete).

@ProviderFor(InventoryController)
const inventoryControllerProvider = InventoryControllerProvider._();

/// A controller for handling actions related to inventory items (add, edit, delete).
final class InventoryControllerProvider
    extends $AsyncNotifierProvider<InventoryController, void> {
  /// A controller for handling actions related to inventory items (add, edit, delete).
  const InventoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryControllerHash();

  @$internal
  @override
  InventoryController create() => InventoryController();
}

String _$inventoryControllerHash() =>
    r'77b7c770b18a0f25696d1c09829ad8c4bd59dd9f';

/// A controller for handling actions related to inventory items (add, edit, delete).

abstract class _$InventoryController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
