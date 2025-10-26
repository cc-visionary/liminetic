// lib/src/features/farm_os/locations/data/location_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_template_model.dart';

/// Repository for managing location data in Firestore.
class LocationRepository {
  final FirebaseFirestore _firestore;

  LocationRepository(this._firestore);

  // A private map associating module names with their specific location types.
  static final Map<String, List<String>> _moduleTemplates = {
    'Swine': ['Building', 'Pen', 'Crate', 'Stall'],
    'Poultry': ['Coop', 'Nest Box'],
    'Crops': ['Greenhouse', 'Field', 'Row', 'Bed'],
  };

  // A private, static list of all possible location templates in the app.
  // This is our fixed catalog and is not fetched from the database.
  static final List<LocationTemplate> _allLocationTemplates = [
    // --- Generic / Universal ---
    LocationTemplate(
      id: 't_building',
      name: 'Building',
      level: 1,
      possibleChildren: ['Pen', 'Stall', 'Room', 'Row'],
    ),
    LocationTemplate(
      id: 't_pasture',
      name: 'Pasture',
      level: 1,
      possibleChildren: ['Paddock', 'Zone'],
    ),
    LocationTemplate(
      id: 't_paddock',
      name: 'Paddock',
      level: 2,
      possibleChildren: ['Shelter'],
    ),
    LocationTemplate(
      id: 't_field',
      name: 'Field',
      level: 1,
      possibleChildren: ['Zone', 'Row'],
    ),

    // --- Swine Module Specific ---
    LocationTemplate(
      id: 't_pen',
      name: 'Pen',
      level: 2,
      possibleChildren: ['Crate', 'Stall'],
    ),
    LocationTemplate(
      id: 't_crate',
      name: 'Crate',
      level: 3,
      possibleChildren: [],
    ),
    LocationTemplate(
      id: 't_stall',
      name: 'Stall',
      level: 3,
      possibleChildren: [],
    ),

    // --- Poultry Module Specific (Example) ---
    LocationTemplate(
      id: 't_coop',
      name: 'Coop',
      level: 2,
      possibleChildren: ['Nest Box'],
    ),
    LocationTemplate(
      id: 't_nest_box',
      name: 'Nest Box',
      level: 3,
      possibleChildren: [],
    ),

    // --- Crop Module Specific (Example) ---
    LocationTemplate(
      id: 't_greenhouse',
      name: 'Greenhouse',
      level: 1,
      possibleChildren: ['Row', 'Bed'],
    ),
    LocationTemplate(id: 't_row', name: 'Row', level: 2, possibleChildren: []),
  ];

  /// Fetches location templates filtered by the farm's active modules.
  ///
  /// For example, if `activeModules` is `['Swine']`, this will only return
  /// templates relevant to swine farming (Building, Pen, Crate, etc.).
  List<LocationTemplate> getLocationTemplates({
    required List<String> activeModules,
  }) {
    if (activeModules.isEmpty) {
      return []; // Return nothing if no modules are active.
    }

    // 1. Get a unique set of all template names allowed by the active modules.
    final allowedTemplateNames = activeModules
        .expand((module) => _moduleTemplates[module] ?? [])
        .toSet();

    // 2. Filter the master list to return only the allowed templates.
    return _allLocationTemplates
        .where((template) => allowedTemplateNames.contains(template.name))
        .toList();
  }

  /// Gets a real-time stream of all locations for a specific farm.
  Stream<List<Location>> getLocationsStream(String farmId) {
    return _firestore
        .collection('farms')
        .doc(farmId)
        .collection('locations')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Location.fromFirestore(doc)).toList(),
        );
  }

  /// Adds a new location document to the farm's subcollection.
  Future<void> addLocation(String farmId, Location location) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('locations')
        .add(location.toMap());
  }

  // TODO: Add methods for updateLocation and deleteLocation later.
}

/// Riverpod provider for the LocationRepository.
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(FirebaseFirestore.instance);
});
