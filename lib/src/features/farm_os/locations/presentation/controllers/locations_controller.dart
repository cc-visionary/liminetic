// lib/src/features/farm_os/locations/presentation/controllers/locations_controller.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/locations/data/location_repository.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';

part 'locations_controller.g.dart';

/// A helper class to structure hierarchical location data.
class LocationNode {
  final Location parent;
  final List<Location> children;
  LocationNode({required this.parent, required this.children});
}

/// A base provider that fetches the raw, flat list of all locations for the active farm.
@riverpod
Stream<List<Location>> rawLocationsStream(Ref ref) {
  final locationRepo = ref.watch(locationRepositoryProvider);
  final farmId = ref.watch(sessionProvider).value?.activeFarm?.id;

  if (farmId == null) {
    return Stream.value([]);
  }
  return locationRepo.getLocationsStream(farmId);
}

/// It watches `rawLocationsStreamProvider`. When the stream emits new data, this
/// provider re-runs its logic, processes the flat list into a hierarchy, and
/// provides the final `List<LocationNode>` to the UI.
@riverpod
List<LocationNode> locations(Ref ref) {
  // Watch the AsyncValue from the raw stream provider.
  final rawLocationsAsync = ref.watch(rawLocationsStreamProvider);

  // Use .maybeWhen to safely handle the data. If the stream is loading or has an
  // error, this will return an empty list, preventing the UI from crashing.
  return rawLocationsAsync.maybeWhen(
    data: (locations) {
      final List<LocationNode> nodes = [];
      final parents = locations
          .where((loc) => loc.parentLocationId == null)
          .toList();

      for (final parent in parents) {
        final children = locations
            .where((loc) => loc.parentLocationId == parent.id)
            .toList();
        nodes.add(LocationNode(parent: parent, children: children));
      }
      return nodes;
    },
    // Return an empty list for loading and error states.
    orElse: () => [],
  );
}

/// Controller for handling actions related to locations, like adding a new one.
@riverpod
class LocationsController extends _$LocationsController {
  @override
  FutureOr<void> build() {
    // No initial state needed.
  }

  /// Adds a batch of new locations to the active farm.
  Future<void> addBatchLocations({
    required List<String> names,
    required String type,
    required int level,
    String? parentLocationId,
  }) async {
    final locationRepo = ref.read(locationRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;

    if (farmId == null) {
      throw Exception('Cannot add locations: No active farm selected.');
    }

    // Create a list of Location objects from the list of names.
    final List<Location> newLocations = names.map((name) {
      return Location(
        id: '', // Firestore will generate the ID.
        name: name,
        type: type,
        level: level,
        parentLocationId: parentLocationId,
      );
    }).toList();

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => locationRepo.addBatchLocations(farmId, newLocations),
    );
  }

  /// Updates an existing location's details.
  Future<void> updateLocation({
    required String locationId,
    required String newName,
  }) async {
    final locationRepo = ref.read(locationRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm found.');

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => locationRepo.updateLocation(farmId, locationId, {'name': newName}),
    );
  }

  /// Deletes an existing location.
  Future<void> deleteLocation(String locationId) async {
    final locationRepo = ref.read(locationRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm found.');

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => locationRepo.deleteLocation(farmId, locationId),
    );
  }
}
