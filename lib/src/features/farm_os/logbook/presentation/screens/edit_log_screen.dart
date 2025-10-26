// lib/src/features/farm_os/logbook/presentation/screens/edit_log_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/controllers/logbook_controller.dart';

/// A screen to edit the details of an existing log entry.
class EditLogScreen extends ConsumerStatefulWidget {
  final LogEntry log;
  const EditLogScreen({super.key, required this.log});

  @override
  ConsumerState<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends ConsumerState<EditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  // State variables for editable time fields
  DateTime? _timeIn;
  DateTime? _timeOut;

  @override
  void initState() {
    super.initState();
    final payload = widget.log.payload;
    // Initialize text controllers
    _controllers['visitorName'] = TextEditingController(
      text: payload['visitorName'],
    );
    _controllers['purposeOfVisit'] = TextEditingController(
      text: payload['purposeOfVisit'],
    );
    _controllers['supplierName'] = TextEditingController(
      text: payload['supplierName'],
    );
    _controllers['itemsReceived'] = TextEditingController(
      text: payload['itemsReceived'],
    );
    _controllers['notes'] = TextEditingController(text: payload['notes']);

    // Initialize DateTime state from Timestamps in payload
    if (payload['timeIn'] is Timestamp) {
      _timeIn = (payload['timeIn'] as Timestamp).toDate();
    }
    if (payload['timeOut'] is Timestamp) {
      _timeOut = (payload['timeOut'] as Timestamp).toDate();
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  /// Shows a time picker and updates the local state.
  Future<void> _selectTime(
    BuildContext context, {
    required bool isTimeIn,
  }) async {
    final initialTime = TimeOfDay.fromDateTime(
      isTimeIn ? (_timeIn ?? DateTime.now()) : (_timeOut ?? DateTime.now()),
    );
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      setState(() {
        if (isTimeIn) {
          _timeIn = DateTime(
            now.year,
            now.month,
            now.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _timeOut = DateTime(
            now.year,
            now.month,
            now.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      });
    }
  }

  /// Validates the form, builds the new payload, and calls the controller.
  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newPayload = <String, dynamic>{};
    // Re-build the payload based on the log type.
    switch (widget.log.type) {
      case LogType.visitorEntry:
        newPayload['visitorName'] = _controllers['visitorName']!.text.trim();
        newPayload['purposeOfVisit'] = _controllers['purposeOfVisit']!.text
            .trim();
        newPayload['timeIn'] = _timeIn != null
            ? Timestamp.fromDate(_timeIn!)
            : null;
        newPayload['timeOut'] = _timeOut != null
            ? Timestamp.fromDate(_timeOut!)
            : null;
        newPayload['locationsVisited'] = widget.log.payload['locationsVisited'];
        break;
      case LogType.deliveryReceived:
        newPayload['supplierName'] = _controllers['supplierName']!.text.trim();
        newPayload['itemsReceived'] = _controllers['itemsReceived']!.text
            .trim();
        break;
      case LogType.generalObservation:
        newPayload['notes'] = _controllers['notes']!.text.trim();
        break;
      default:
        break;
    }

    try {
      await ref
          .read(logbookControllerProvider.notifier)
          .editLogEntry(widget.log.id, newPayload);
      if (mounted) context.go('/logs');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final logbookState = ref.watch(logbookControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Log Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display the log type as non-editable text.
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Log Type',
                  border: InputBorder.none,
                ),
                child: Text(
                  widget.log.type.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 16),
              // Dynamically build the form fields for editing.
              ..._buildDynamicFormFields(widget.log.type),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: logbookState.isLoading ? null : _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the list of editable form fields based on the log type.
  List<Widget> _buildDynamicFormFields(LogType type) {
    switch (type) {
      case LogType.visitorEntry:
        return [
          TextFormField(
            controller: _controllers['visitorName'],
            decoration: const InputDecoration(labelText: 'Visitor Name'),
            validator: (v) => v!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controllers['purposeOfVisit'],
            decoration: const InputDecoration(labelText: 'Purpose of Visit'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Time In',
                    hintText: _timeIn == null
                        ? 'Select time'
                        : DateFormat.jm().format(_timeIn!),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  onTap: () => _selectTime(context, isTimeIn: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Time Out',
                    hintText: _timeOut == null
                        ? '--:--'
                        : DateFormat.jm().format(_timeOut!),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  onTap: () => _selectTime(context, isTimeIn: false),
                ),
              ),
            ],
          ),
        ];
      case LogType.deliveryReceived:
        return [
          TextFormField(
            controller: _controllers['supplierName'],
            decoration: const InputDecoration(labelText: 'Supplier Name'),
            validator: (v) => v!.isEmpty ? 'Supplier is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controllers['itemsReceived'],
            decoration: const InputDecoration(
              labelText: 'Items Received (comma-separated)',
            ),
            maxLines: 3,
          ),
        ];
      case LogType.generalObservation:
        return [
          TextFormField(
            controller: _controllers['notes'],
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 5,
            validator: (v) => v!.isEmpty ? 'Note is required' : null,
          ),
        ];
      default:
        return [const Text('This log type cannot be edited.')];
    }
  }
}
