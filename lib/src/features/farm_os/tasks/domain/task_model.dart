// lib/src/features/farm_os/tasks/domain/task_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// An enum representing the possible statuses of a Task.
enum TaskStatus {
  pending,
  inProgress,
  completed,
  urgent,
  overdue;

  // Helper to convert a string from Firestore to our enum.
  static TaskStatus fromString(String status) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TaskStatus.pending,
    );
  }
}

/// Represents a single task within a farm.
class Task {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final String createdBy;
  final String? assigneeId; // The UID of the FarmMember assigned to this task.

  // A list to hold linked inventory items and their quantities.
  // e.g., [{'itemId': 'abc', 'itemName': 'Vaccine A', 'quantityUsed': 2.5}]
  final List<Map<String, dynamic>> linkedInventory;

  final String? locationId; // The ID of the Location this task is linked to.
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdBy,
    this.assigneeId,
    this.linkedInventory = const [],
    this.locationId,
    this.dueDate,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      status: TaskStatus.fromString(data['status'] ?? 'pending'),
      createdBy: data['createdBy'] ?? '',
      assigneeId: data['assigneeId'],
      linkedInventory: List<Map<String, dynamic>>.from(
        data['linkedInventory'] ?? [],
      ),
      locationId: data['locationId'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.name, // Save the enum name as a string.
      'createdBy': createdBy,
      'assigneeId': assigneeId,
      'linkedInventory': linkedInventory,
      'locationId': locationId,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    };
  }
}
