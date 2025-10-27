// lib/src/features/farm_os/inventory/domain/inventory_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single, trackable item in the farm's inventory.
class InventoryItem {
  final String id;
  final String name;
  final String category; // e.g., "Feeds", "Medicines", "Supplies"
  final double quantity; // The current stock level.
  final String unit; // e.g., "Sacks", "Bottles", "kg"
  final double lowStockThreshold; // A threshold to trigger low stock warnings.

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.lowStockThreshold,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'General',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? '',
      lowStockThreshold: (data['lowStockThreshold'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'lowStockThreshold': lowStockThreshold,
    };
  }
}