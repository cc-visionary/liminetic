// lib/src/features/farm_os/tasks/presentation/screens/create_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/common_widgets/general_form_params_provider.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/settings/team/domain/farm_member_model.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/controllers/tasks_controller.dart';

/// A helper class to manage the UI state of a single linked inventory item.
class LinkedInventoryItem {
  final InventoryItem item;
  final TextEditingController quantityController = TextEditingController();
  LinkedInventoryItem({required this.item});
  void dispose() => quantityController.dispose();
}

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
  final List<LinkedInventoryItem> _linkedItems = [];

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

  /// Shows a dialog to select an inventory item to link to the task.
  Future<void> _showSelectInventoryDialog(List<InventoryItem> allItems) async {
    final availableItems = allItems
        .where((i) => !_linkedItems.any((li) => li.item.id == i.id))
        .toList();
    final selectedItem = await showDialog<InventoryItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Inventory Item'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableItems.length,
            itemBuilder: (context, index) {
              final item = availableItems[index];
              return ListTile(
                title: Text(item.name),
                onTap: () => Navigator.of(context).pop(item),
              );
            },
          ),
        ),
      ),
    );

    if (selectedItem != null) {
      setState(() => _linkedItems.add(LinkedInventoryItem(item: selectedItem)));
    }
  }

  /// Validates the form and calls the controller to save the new task.
  Future<void> _saveTask() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final linkedInventoryData = _linkedItems.map((li) {
      return {
        'itemId': li.item.id,
        'itemName': li.item.name, // Denormalize name for easy display in logs
        'quantityUsed': double.tryParse(li.quantityController.text) ?? 0.0,
      };
    }).toList();

    try {
      await ref
          .read(tasksControllerProvider.notifier)
          .addTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            assigneeId: _selectedAssignee?.uid,
            locationId: _selectedLocation?.id,
            dueDate: _selectedDueDate,
            linkedInventory: linkedInventoryData,
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
    final formParamsAsync = ref.watch(generalFormParamsProvider);
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
                  Text(
                    'Linked Inventory',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_linkedItems.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _linkedItems.length,
                      itemBuilder: (context, index) {
                        final linkedItem = _linkedItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(linkedItem.item.name),
                            subtitle: SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: linkedItem.quantityController,
                                decoration: InputDecoration(
                                  labelText: 'Quantity to Use',
                                  suffixText: linkedItem.item.unit,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) =>
                                    (v?.isEmpty ?? true) ? 'Req.' : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  setState(() => _linkedItems.removeAt(index)),
                            ),
                          ),
                        );
                      },
                    ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showSelectInventoryDialog(params.inventoryItems),
                    icon: const Icon(Icons.add),
                    label: const Text('Link Item'),
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
