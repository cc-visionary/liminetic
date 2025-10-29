// lib/src/features/farm_os/logbook/domain/log_entry_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// An enum representing all possible categories of a log entry.
enum LogType {
  // Animal-Specific
  healthStatus,
  treatmentAdministered,
  birth,
  weaning,
  death,
  // Operational
  feeding,
  movement,
  event,
  // Business & Biosecurity
  visitorEntry,
  deliveryReceived,
  inventoryRestock,
  inventoryUsage,
  sale,
  // General
  generalObservation;

  static LogType fromString(String status) {
    return LogType.values.firstWhere(
      (e) => e.name == status,
      orElse: () => LogType.generalObservation,
    );
  }
}

/// Represents a single, flexible entry in the farm's logbook.
/// It contains core fields and a flexible `payload` map for type-specific data.
class LogEntry {
  final String id;
  final LogType type;
  final Timestamp timestamp;
  final String actorId; // UID of the user or "system" for automated logs.
  final String actorName; // Denormalized name of the user/system.
  final Map<String, dynamic> payload; // Flexible data for different log types.

  LogEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.actorId,
    required this.actorName,
    required this.payload,
  });

  factory LogEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogEntry(
      id: doc.id,
      type: LogType.fromString(data['type'] ?? 'generalObservation'),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      actorId: data['actorId'] ?? '',
      actorName: data['actorName'] ?? 'Unknown',
      payload: data['payload'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'timestamp': timestamp,
      'actorId': actorId,
      'actorName': actorName,
      'payload': payload,
    };
  }

  // --- UI Helper Getters ---
  // The model itself knows how to present its data. This keeps the UI layer clean.

  /// Generates a human-readable title based on the log type.
  String get title {
    switch (type) {
      case LogType.visitorEntry:
        return 'Visitor Arrival: ${payload['visitorName'] ?? 'N/A'}';
      case LogType.deliveryReceived:
        return 'Delivery from ${payload['supplierName'] ?? 'N/A'}';
      case LogType.inventoryUsage:
        return '${payload['quantityUsed']} of ${payload['itemName']} used';
      case LogType.healthStatus:
        return 'Health Observation Logged';
      case LogType.sale:
        return 'Sale to ${payload['customerName'] ?? 'Customer'}';
      // Add more cases for other log types...
      default:
        return 'General Log Entry';
    }
  }

  /// Generates a human-readable subtitle (actor and time).
  String get subtitle {
    final time = DateFormat('MMM d, h:mm a').format(timestamp.toDate());
    return '$actorName • $time';
  }

  /// Returns an appropriate icon for the log type.
  IconData get icon {
    switch (type) {
      case LogType.visitorEntry:
        return Icons.person_outline;
      case LogType.deliveryReceived:
        return Icons.local_shipping_outlined;
      case LogType.healthStatus:
        return Icons.monitor_heart_outlined;
      case LogType.inventoryUsage:
        return Icons.remove_circle_outline;
      case LogType.movement:
        return Icons.sync_alt;
      case LogType.sale:
        return Icons.monetization_on_outlined;
      // Add more cases...
      default:
        return Icons.notes_outlined;
    }
  }
}
