// lib/src/features/farm_os/tasks/presentation/screens/edit_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/tasks/domain/task_model.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/controllers/create_task_controller.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/controllers/tasks_controller.dart';
import 'package:liminetic/src/features/farm_os/settings/team/domain/farm_member_model.dart';

/// A screen with a form to edit an existing task.
class EditTaskScreen extends ConsumerStatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  
  FarmMember? _selectedAssignee;
  Location? _selectedLocation;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form fields with the existing task data.
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDueDate = widget.task.dueDate;

    // Asynchronously fetch form data and then find the matching objects for the dropdowns.
    _initializeDropdowns();
  }

  /// Fetches dropdown data and sets the initial selected values.
  void _initializeDropdowns() {
    ref.read(createTaskFormParamsProvider.future).then((params) {
      if (!mounted) return;

      // **THE FIX**: Use a try-catch block to safely find the matching items.
      // This correctly handles cases where the assignee or location might have been deleted.
      FarmMember? initialAssignee;
      Location? initialLocation;

      try {
        initialAssignee = params.teamMembers.firstWhere((m) => m.uid == widget.task.assigneeId);
      } catch (e) {
        initialAssignee = null; // Not found, so leave it null
      }

      try {
        initialLocation = params.locations.firstWhere((l) => l.id == widget.task.locationId);
      } catch (e) {
        initialLocation = null; // Not found, so leave it null
      }

      setState(() {
        _selectedAssignee = initialAssignee;
        _selectedLocation = initialLocation;
      });
    });
  }

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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  /// Validates the form and calls the controller to save the changes.
  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ref.read(tasksControllerProvider.notifier).editTask(
            taskId: widget.task.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            assigneeId: _selectedAssignee?.uid,
            locationId: _selectedLocation?.id,
            dueDate: _selectedDueDate,
          );
      // On success, go back to the main tasks list.
      if (mounted) context.go('/tasks');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formParamsAsync = ref.watch(createTaskFormParamsProvider);
    final tasksState = ref.watch(tasksControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: formParamsAsync.when(
        data: (params) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FarmMember>(
                  value: _selectedAssignee,
                  decoration: const InputDecoration(labelText: 'Assign To'),
                  items: params.teamMembers.map((member) => DropdownMenuItem(value: member, child: Text(member.username))).toList(),
                  onChanged: (member) => setState(() => _selectedAssignee = member),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Location>(
                  value: _selectedLocation,
                  decoration: const InputDecoration(labelText: 'Link to Location'),
                  items: params.locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc.name))).toList(),
                  onChanged: (loc) => setState(() => _selectedLocation = loc),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    hintText: _selectedDueDate == null ? 'mm/dd/yyyy' : DateFormat.yMMMd().format(_selectedDueDate!),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  onTap: _selectDueDate,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: tasksState.isLoading ? null : _saveChanges,
                  child: tasksState.isLoading ? const CircularProgressIndicator() : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading form: $e')),
      ),
    );
  }
}