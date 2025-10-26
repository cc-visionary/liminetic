// lib/src/features/farm_os/tasks/presentation/screens/tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/common_widgets/filter_chip_row.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/farm_os/tasks/domain/task_model.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/controllers/tasks_controller.dart';

// Mapping between enum and display string for the filter widget
const Map<TaskFilter, String> taskFilterMap = {
  TaskFilter.allTasks: 'All Tasks',
  TaskFilter.myTasks: 'My Tasks',
  TaskFilter.open: 'Open',
  TaskFilter.overdue: 'Overdue',
};

/// The main screen for viewing and managing farm tasks.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the raw stream for loading/error states and the derived provider for the data.
    final tasksAsyncValue = ref.watch(rawTasksStreamProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(tasksFilterProvider);

    return ResponsiveScaffold(
      title: 'Tasks',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/create-task'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          FilterChipRow(
            options: taskFilterMap.values.toList(), // Use display names
            selectedValue: taskFilterMap[currentFilter]!,
            onSelected: (label) {
              // Convert the display name back to the enum value before updating state.
              final newFilter = taskFilterMap.entries
                  .firstWhere((e) => e.value == label)
                  .key;
              ref.read(tasksFilterProvider.notifier).setFilter(newFilter);
            },
          ),
          Expanded(
            child: tasksAsyncValue.when(
              data: (_) {
                if (filteredTasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks found for this filter.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return _TaskCard(task: task);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

/// A card widget to display a single task.
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final Task task;

  String _formatDueDate(DateTime? date) {
    if (date == null) return 'No due date';
    // Use intl package for robust date formatting.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Due: Today';
    }
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Due: Tomorrow';
    }
    return 'Due: ${DateFormat.yMMMd().format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatDueDate(task.dueDate)),
        trailing: _StatusChip(status: task.status),
        onTap: () {
          context.push('/tasks/${task.id}', extra: task);
        },
      ),
    );
  }
}

/// A chip to visually represent the task's status.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String label;
    switch (status) {
      case TaskStatus.urgent:
        backgroundColor = Colors.red.shade100;
        label = 'Urgent';
        break;
      case TaskStatus.inProgress:
        backgroundColor = Colors.yellow.shade200;
        label = 'In Progress';
        break;
      case TaskStatus.pending:
        backgroundColor = Colors.blue.shade100;
        label = 'Pending';
        break;
      case TaskStatus.completed:
        backgroundColor = Colors.green.shade100;
        label = 'Completed';
        break;
      case TaskStatus.overdue:
        backgroundColor = Colors.orange.shade100;
        label = 'Overdue';
        break;
    }
    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
