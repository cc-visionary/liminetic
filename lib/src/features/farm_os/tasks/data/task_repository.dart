// lib/src/features/farm_os/tasks/data/task_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/features/farm_os/tasks/domain/task_model.dart';

/// Repository for managing task data in the `/farms/{farmId}/tasks` subcollection.
class TaskRepository {
  final FirebaseFirestore _firestore;
  TaskRepository(this._firestore);
  
  /// Gets a real-time stream of all tasks for a specific farm.
  Stream<List<Task>> getTasksStream(String farmId) {
    return _firestore
        .collection('farms')
        .doc(farmId)
        .collection('tasks')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }


  /// Adds a new task document to the subcollection.
  /// TODO: list of existing task templates, based on activated modules
  Future<void> addTask(String farmId, Task task) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('tasks')
        .add(task.toMap());
  }

  /// Updates a specific task document.
  Future<void> updateTask(
    String farmId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('tasks')
        .doc(taskId)
        .update(data);
  }

  Future<void> deleteTask(String farmId, String taskId) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}

/// Riverpod provider for the TaskRepository.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(FirebaseFirestore.instance);
});
