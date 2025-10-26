// lib/src/features/farm_os/locations/domain/location_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a specific location instance within a farm (e.g., "Main Barn").
///
/// This model supports a hierarchical structure through `parentLocationId` and
/// will eventually hold coordinates for map placement.
class Location {
  final String id;
  final String name; // e.g., "Pen #12"
  final String type; // e.g., "Pen", "Building" (matches a template name)
  final int level; // The hierarchy level of this location.
  final String? parentLocationId; // ID of the parent location, if any

  // Optional fields for the map layout editor
  final double? x;
  final double? y;
  final double? width;
  final double? height;

  Location({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    this.parentLocationId,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  factory Location.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Location(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      level: data['level'] ?? 1,
      parentLocationId: data['parentLocationId'],
      x: data['x'],
      y: data['y'],
      width: data['width'],
      height: data['height'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'level': level,
      'parentLocationId': parentLocationId,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}
