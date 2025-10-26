// lib/src/features/farm_os/locations/domain/location_template_model.dart

/// Represents a template for a type of location from the global collection.
///
/// This model defines the universal properties of a location type, such as
/// its name (e.g., "Building"), the level it belongs to in the hierarchy,
/// and what types of children it can have.
class LocationTemplate {
  final String id;
  final String name; // e.g., "Building", "Pen", "Paddock"
  final int
  level; // The hierarchy level (1 for top-level, 2 for sub-level, etc.)
  final List<String>
  possibleChildren; // List of template names that can be children

  LocationTemplate({
    required this.id,
    required this.name,
    required this.level,
    required this.possibleChildren,
  });

  // You would typically have a from Firestore factory constructor here
}
