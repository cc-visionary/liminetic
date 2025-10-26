// lib/src/features/farm_os/tasks/presentation/screens/task_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';
import 'package:liminetic/src/features/farm_os/settings/team/presentation/controllers/team_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/farm_os/tasks/domain/task_model.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/controllers/tasks_controller.dart';

part 'task_details_screen.g.dart';

/// A provider to resolve an assignee's ID to their username.
@riverpod
Future<String> assigneeName(Ref ref, String? assigneeId) async {
  if (assigneeId == null) return 'Unassigned';
  final team = await ref.watch(teamProvider.future);
  try {
    return team.firstWhere((member) => member.uid == assigneeId).username;
  } catch (e) {
    return 'Unknown User';
  }
}

/// A provider to resolve a location's ID to its name.
@riverpod
Future<String> locationName(Ref ref, String? locationId) async {
  if (locationId == null) return 'No Location';
  final locations = await ref.watch(rawLocationsStreamProvider.future);
  try {
    return locations.firstWhere((loc) => loc.id == locationId).name;
  } catch (e) {
    return 'Unknown Location';
  }
}

/// A screen that shows the details of a single task.
class TaskDetailsScreen extends ConsumerWidget {
  final Task task;
  const TaskDetailsScreen({super.key, required this.task});

  /// Shows a confirmation dialog before deleting the task.
  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text(
          'Are you sure you want to delete this task permanently?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(tasksControllerProvider.notifier).deleteTask(task.id);
        if (context.mounted) context.pop();
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksControllerProvider);
    final theme = Theme.of(context);

    final assigneeNameAsync = ref.watch(assigneeNameProvider(task.assigneeId));
    final locationNameAsync = ref.watch(locationNameProvider(task.locationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/tasks/${task.id}/edit', extra: task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteTask(context, ref),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // TODO: Use the _StatusChip widget from tasks_screen.dart here
                  Chip(label: Text(task.status.name)),
                  const SizedBox(height: 24),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    Text('Description', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(task.description!, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 24),
                  ],
                  Text('Assigned To', style: theme.textTheme.titleMedium),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: assigneeNameAsync.when(
                        data: (name) => Text(name),
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Error'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Location', style: theme.textTheme.titleMedium),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.location_on_outlined),
                      ),
                      title: locationNameAsync.when(
                        data: (name) => Text(name),
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Error'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: tasksState.isLoading
                  ? null
                  : () async {
                      // TODO: Here is where you will add logic for other modules.
                      // For now, it just completes the task.
                      try {
                        await ref
                            .read(tasksControllerProvider.notifier)
                            .updateTaskStatus(task.id, TaskStatus.completed);
                        if (context.mounted) context.pop();
                      } catch (e) {
                        // handle error
                      }
                    },
              child: const Text('Mark as Complete'),
            ),
          ),
        ],
      ),
    );
  }
}
