// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A base provider that fetches the raw, flat list of all locations for the active farm.

@ProviderFor(rawLocationsStream)
const rawLocationsStreamProvider = RawLocationsStreamProvider._();

/// A base provider that fetches the raw, flat list of all locations for the active farm.

final class RawLocationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Location>>,
          List<Location>,
          Stream<List<Location>>
        >
    with $FutureModifier<List<Location>>, $StreamProvider<List<Location>> {
  /// A base provider that fetches the raw, flat list of all locations for the active farm.
  const RawLocationsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rawLocationsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rawLocationsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Location>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Location>> create(Ref ref) {
    return rawLocationsStream(ref);
  }
}

String _$rawLocationsStreamHash() =>
    r'464a029f039bf84e90cb025ec7cc094cb1640e6b';

/// It watches `rawLocationsStreamProvider`. When the stream emits new data, this
/// provider re-runs its logic, processes the flat list into a hierarchy, and
/// provides the final `List<LocationNode>` to the UI.

@ProviderFor(locations)
const locationsProvider = LocationsProvider._();

/// It watches `rawLocationsStreamProvider`. When the stream emits new data, this
/// provider re-runs its logic, processes the flat list into a hierarchy, and
/// provides the final `List<LocationNode>` to the UI.

final class LocationsProvider
    extends
        $FunctionalProvider<
          List<LocationNode>,
          List<LocationNode>,
          List<LocationNode>
        >
    with $Provider<List<LocationNode>> {
  /// It watches `rawLocationsStreamProvider`. When the stream emits new data, this
  /// provider re-runs its logic, processes the flat list into a hierarchy, and
  /// provides the final `List<LocationNode>` to the UI.
  const LocationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationsHash();

  @$internal
  @override
  $ProviderElement<List<LocationNode>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<LocationNode> create(Ref ref) {
    return locations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LocationNode> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LocationNode>>(value),
    );
  }
}

String _$locationsHash() => r'64a5cb33850af52c877cde9d2a4b201c77298239';

/// Controller for handling actions related to locations, like adding a new one.

@ProviderFor(LocationsController)
const locationsControllerProvider = LocationsControllerProvider._();

/// Controller for handling actions related to locations, like adding a new one.
final class LocationsControllerProvider
    extends $AsyncNotifierProvider<LocationsController, void> {
  /// Controller for handling actions related to locations, like adding a new one.
  const LocationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationsControllerHash();

  @$internal
  @override
  LocationsController create() => LocationsController();
}

String _$locationsControllerHash() =>
    r'53040ee78a3f8affe6357f4749201900681da86b';

/// Controller for handling actions related to locations, like adding a new one.

abstract class _$LocationsController extends $AsyncNotifier<void> {
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
