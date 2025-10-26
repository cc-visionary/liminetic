// lib/src/features/farm_os/locations/presentation/controllers/add_location_controller.dart

import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/farm_os/locations/data/location_repository.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_template_model.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';

part 'add_location_controller.g.dart';

/// A helper class to hold all the raw data needed for the 'Add Location' form.
class LocationFormParams {
  final List<LocationTemplate> allTemplates;
  final List<Location> allLocations; // Flat list of all existing locations

  LocationFormParams({required this.allTemplates, required this.allLocations});
}

/// The addLocationFormParamsProvider needs to know about active modules.
@riverpod
Future<LocationFormParams> addLocationFormParams(Ref ref) async {
  final locationRepo = ref.watch(locationRepositoryProvider);
  
  // Get the active modules from the current farm session.
  final activeModules = ref.watch(sessionProvider).value?.activeFarm?.activeModules ?? [];
  final allLocations = await ref.watch(rawLocationsStreamProvider.future);

  // Pass the active modules to the repository method.
  final templates = locationRepo.getLocationTemplates(activeModules: activeModules);

  return LocationFormParams(allTemplates: templates, allLocations: allLocations);
}
