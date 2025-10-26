// lib/src/features/farm_os/tasks/presentation/screens/create_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/settings/team/domain/farm_member_model.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/controllers/create_task_controller.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/controllers/tasks_controller.dart';

/// A screen with a form to create a new task.
class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  FarmMember? _selectedAssignee;
  Location? _selectedLocation;
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Shows a date picker to select the task's due date.
  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ), // Allow recent past dates
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  /// Validates the form and calls the controller to save the new task.
  Future<void> _saveTask() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ref
          .read(tasksControllerProvider.notifier)
          .addTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            assigneeId: _selectedAssignee?.uid,
            locationId: _selectedLocation?.id,
            dueDate: _selectedDueDate,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formParamsAsync = ref.watch(createTaskFormParamsProvider);
    final tasksState = ref.watch(tasksControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: formParamsAsync.when(
        data: (params) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<FarmMember>(
                    value: _selectedAssignee,
                    decoration: const InputDecoration(labelText: 'Assign To'),
                    items: params.teamMembers
                        .map(
                          (member) => DropdownMenuItem(
                            value: member,
                            child: Text(member.username),
                          ),
                        )
                        .toList(),
                    onChanged: (member) =>
                        setState(() => _selectedAssignee = member),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Location>(
                    value: _selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'Link to Location',
                    ),
                    items: params.locations
                        .map(
                          (loc) => DropdownMenuItem(
                            value: loc,
                            child: Text(loc.name),
                          ),
                        )
                        .toList(),
                    onChanged: (loc) => setState(() => _selectedLocation = loc),
                  ),
                  const SizedBox(height: 16),
                  // TODO: don't allow setting the date to previous today
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      hintText: _selectedDueDate == null
                          ? 'mm/dd/yyyy'
                          : DateFormat.yMMMd().format(_selectedDueDate!),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: _selectDueDate,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: tasksState.isLoading ? null : _saveTask,
                    child: tasksState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Task'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading form: $e')),
      ),
    );
  }
}
