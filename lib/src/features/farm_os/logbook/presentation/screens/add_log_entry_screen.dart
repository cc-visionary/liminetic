// lib/src/features/farm_os/logbook/presentation/screens/add_log_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/controllers/logbook_controller.dart';

class AddLogEntryScreen extends ConsumerStatefulWidget {
  final LogType? preselectedType;
  const AddLogEntryScreen({super.key, this.preselectedType});

  @override
  ConsumerState<AddLogEntryScreen> createState() => _AddLogEntryScreenState();
}

class _AddLogEntryScreenState extends ConsumerState<AddLogEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  LogType? _selectedLogType;

  final Map<String, TextEditingController> _controllers = {};
  DateTime? _timeIn;
  DateTime? _timeOut;

  @override
  void initState() {
    super.initState();
    _selectedLogType = widget.preselectedType;
    _controllers['name'] = TextEditingController();
    _controllers['purpose'] = TextEditingController();
    _controllers['supplier'] = TextEditingController();
    _controllers['items'] = TextEditingController();
    _controllers['notes'] = TextEditingController();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = <String, dynamic>{};
    switch (_selectedLogType!) {
      case LogType.visitorEntry:
        if (_timeIn == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a "Time In".')),
          );
          return;
        }
        payload['visitorName'] = _controllers['name']!.text.trim();
        payload['purposeOfVisit'] = _controllers['purpose']!.text.trim();
        payload['timeIn'] = _timeIn;
        payload['timeOut'] = _timeOut;
        break;
      case LogType.deliveryReceived:
        payload['supplierName'] = _controllers['supplier']!.text.trim();
        payload['itemsReceived'] = _controllers['items']!.text.trim();
        break;
      case LogType.generalObservation:
        payload['notes'] = _controllers['notes']!.text.trim();
        break;
      default:
        break;
    }

    try {
      await ref
          .read(logbookControllerProvider.notifier)
          .addLogEntry(type: _selectedLogType!, payload: payload);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  /// Shows a time picker and updates the state.
  Future<void> _selectTime(
    BuildContext context, {
    required bool isTimeIn,
  }) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  @override
  Widget build(BuildContext context) {
    final logbookState = ref.watch(logbookControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.preselectedType != null
              ? 'New ${_getLogTypeDisplayName(widget.preselectedType!)}'
              : 'New Log Entry',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<LogType>(
                value: _selectedLogType,
                decoration: const InputDecoration(labelText: 'Log Type'),
                onChanged: widget.preselectedType != null
                    ? null
                    : (type) => setState(() => _selectedLogType = type),
                items:
                    [
                          LogType.visitorEntry,
                          LogType.deliveryReceived,
                          LogType.generalObservation,
                        ]
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(_getLogTypeDisplayName(type)),
                          ),
                        )
                        .toList(),
                validator: (value) =>
                    value == null ? 'Please select a log type' : null,
              ),
              const SizedBox(height: 24),
              if (_selectedLogType != null)
                ..._buildDynamicFormFields(_selectedLogType!),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: logbookState.isLoading || _selectedLogType == null
                    ? null
                    : _saveEntry,
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicFormFields(LogType type) {
    switch (type) {
      case LogType.visitorEntry:
        return [
          TextFormField(
            controller: _controllers['name'],
            decoration: const InputDecoration(labelText: 'Visitor Name'),
            validator: (v) => v!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controllers['purpose'],
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
            controller: _controllers['supplier'],
            decoration: const InputDecoration(labelText: 'Supplier Name'),
            validator: (v) => v!.isEmpty ? 'Supplier is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controllers['items'],
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
        return [const Text('No form available for this log type yet.')];
    }
  }

  String _getLogTypeDisplayName(LogType type) {
    switch (type) {
      case LogType.visitorEntry:
        return 'Visitor / Biosecurity Entry';
      case LogType.deliveryReceived:
        return 'Delivery Received';
      case LogType.generalObservation:
        return 'General Observation';
      default:
        return type.name;
    }
  }
}
