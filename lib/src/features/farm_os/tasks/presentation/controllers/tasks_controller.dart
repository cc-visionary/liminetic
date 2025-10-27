// lib/src/features/farm_os/tasks/presentation/controllers/tasks_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/tasks/data/task_repository.dart';
import 'package:liminetic/src/features/farm_os/tasks/domain/task_model.dart';

part 'tasks_controller.g.dart';

/// An enum to represent the available filters on the Tasks screen.
enum TaskFilter { allTasks, myTasks, open, overdue }

/// A simple provider to hold the currently selected filter state.
/// The UI will update this provider when the user taps a filter chip.
@riverpod
class TasksFilter extends _$TasksFilter {
  @override
  TaskFilter build() => TaskFilter.allTasks; // Default filter

  void setFilter(TaskFilter filter) {
    state = filter;
  }
}

/// A base provider that fetches a raw, unfiltered stream of all tasks for the farm.
@riverpod
Stream<List<Task>> rawTasksStream(Ref ref) {
  final taskRepo = ref.watch(taskRepositoryProvider);
  final farmId = ref.watch(sessionProvider).value?.activeFarm?.id;
  if (farmId == null) return Stream.value([]);
  return taskRepo.getTasksStream(farmId);
}

/// A derived provider that filters the raw list of tasks based on the selected filter.
/// The UI will watch this provider to display the final, filtered list.
@riverpod
List<Task> filteredTasks(Ref ref) {
  // Watch the raw data and the current filter.
  final tasksAsyncValue = ref.watch(rawTasksStreamProvider);
  final filter = ref.watch(tasksFilterProvider);
  final currentUserId = ref.watch(sessionProvider).value?.appUser?.uid;

  return tasksAsyncValue.maybeWhen(
    data: (tasks) {
      // Apply the selected filter logic.
      switch (filter) {
        case TaskFilter.myTasks:
          return tasks
              .where((task) => task.assigneeId == currentUserId)
              .toList();
        case TaskFilter.open:
          return tasks
              .where((task) => task.status != TaskStatus.completed)
              .toList();
        case TaskFilter.overdue:
          final now = DateTime.now();
          return tasks.where((task) {
            return task.dueDate != null &&
                task.dueDate!.isBefore(now) &&
                task.status != TaskStatus.completed;
          }).toList();
        default:
          return tasks;
      }
    },
    orElse: () => [], // Return an empty list on loading or error.
  );
}

/// A controller for handling actions related to tasks.
@riverpod
class TasksController extends _$TasksController {
  @override
  FutureOr<void> build() {}

  //// Adds a new task to the database.
  Future<void> addTask({
    required String title,
    String? description,
    String? assigneeId,
    String? locationId,
    DateTime? dueDate,
  }) async {
    final taskRepo = ref.read(taskRepositoryProvider);
    final session = ref.read(sessionProvider).value;
    final farmId = session?.activeFarm?.id;
    final creatorId = session?.appUser?.uid;

    if (farmId == null || creatorId == null) {
      throw Exception('Cannot add task: Active session not found.');
    }

    // Create the new Task object here.
    final newTask = Task(
      id: '', // Firestore generates the ID
      title: title,
      description: description,
      status: TaskStatus.pending, // New tasks always start as pending
      createdBy: creatorId,
      assigneeId: assigneeId,
      locationId: locationId,
      dueDate: dueDate,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => taskRepo.addTask(farmId, newTask));
  }

  /// Edits an existing task with new details.
  Future<void> editTask({
    required String taskId,
    required String title,
    String? description,
    String? assigneeId,
    String? locationId,
    DateTime? dueDate,
  }) async {
    final taskRepo = ref.read(taskRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm found.');

    // Prepare a map of the data to be updated.
    final updateData = {
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'locationId': locationId,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
    };

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => taskRepo.updateTask(farmId, taskId, updateData),
    );
  }

  /// Updates an existing task's status.
  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final taskRepo = ref.read(taskRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm found.');
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => taskRepo.updateTask(farmId, taskId, {'status': newStatus.name}),
    );
  }

  /// Deletes a task from the database.
  Future<void> deleteTask(String taskId) async {
    final taskRepo = ref.read(taskRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm found.');

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => taskRepo.deleteTask(farmId, taskId));
  }
}
