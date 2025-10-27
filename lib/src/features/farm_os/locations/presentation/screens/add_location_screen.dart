// lib/src/features/farm_os/locations/presentation/screens/add_location_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/common_widgets/general_form_params_provider.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_template_model.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';

class AddLocationScreen extends ConsumerStatefulWidget {
  const AddLocationScreen({super.key});

  @override
  ConsumerState<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  // Manage a list of controllers, initialized with one for the first field.
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
  ];

  LocationTemplate? _selectedTemplate;
  Location? _selectedParent;
  List<Location> _potentialParents = [];

  @override
  void dispose() {
    // Dispose all controllers in the list.
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Adds a new, empty text field for another location.
  void _addLocationField() {
    setState(() {
      _nameControllers.add(TextEditingController());
    });
  }

  /// Removes a specific text field.
  void _removeLocationField(int index) {
    // Cannot remove the last field.
    if (_nameControllers.length > 1) {
      setState(() {
        // Dispose the controller before removing it.
        _nameControllers[index].dispose();
        _nameControllers.removeAt(index);
      });
    }
  }

  /// Collects all names and calls the batch save method.
  Future<void> _saveLocations() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Filter out any empty names before saving.
    final names = _nameControllers
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one location name.'),
        ),
      );
      return;
    }

    try {
      // Call the new batch method in the controller.
      await ref
          .read(locationsControllerProvider.notifier)
          .addBatchLocations(
            names: names,
            type: _selectedTemplate!.name,
            level: _selectedTemplate!.level,
            parentLocationId: _selectedParent?.id,
          );

      if (!mounted) return;
      ref.invalidate(rawLocationsStreamProvider);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formParamsAsync = ref.watch(generalFormParamsProvider);
    final locationsControllerState = ref.watch(locationsControllerProvider);

    // Listen for the specific state transition from loading to success.
    ref.listen<AsyncValue<void>>(locationsControllerProvider, (previous, next) {
      // Check that the previous state was loading, and the current state
      // is no longer loading AND has no error. This is the correct way to detect
      // a successful completion for an AsyncValue<void>.
      if ((previous?.isLoading ?? false) && !next.isLoading && !next.hasError) {
        // Safety check to ensure the widget is still mounted before navigating.
        if (!mounted) return;

        // Invalidate the stream to refresh the locations list on the previous screen.
        ref.invalidate(rawLocationsStreamProvider);

        // Confidently pop the screen.
        context.pop();
      }

      // Handle the error state separately.
      if (next.hasError && !next.isLoading) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Location')),
      body: formParamsAsync.when(
        data: (params) {
          final availableTemplates = params.locations.isEmpty
              ? params.templates.where((t) => t.level == 1).toList()
              : params.templates.where((template) {
                  if (template.level == 1) return true;
                  final validParentTypes = params.templates
                      .where(
                        (pt) => pt.possibleChildren.contains(template.name),
                      )
                      .map((pt) => pt.name)
                      .toSet();
                  return params.locations.any(
                    (loc) => validParentTypes.contains(loc.type),
                  );
                }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<LocationTemplate>(
                    value: _selectedTemplate,
                    decoration: const InputDecoration(
                      labelText: 'Location Type',
                    ),
                    items: availableTemplates
                        .map(
                          (template) => DropdownMenuItem(
                            value: template,
                            child: Text(template.name),
                          ),
                        )
                        .toList(),
                    onChanged: (template) {
                      setState(() {
                        _selectedTemplate = template;
                        _selectedParent =
                            null; // Reset parent selection on change.
                        _potentialParents = []; // Clear old parent options.

                        // This is the core logic for the dynamic parent dropdown.
                        if (template != null && template.level > 1) {
                          // 1. Find all TEMPLATE types that are valid parents for the selected child type.
                          final validParentTypes = params.templates
                              .where(
                                (pt) =>
                                    pt.possibleChildren.contains(template.name),
                              )
                              .map((pt) => pt.name)
                              .toList();

                          // 2. Filter the list of EXISTING locations to find actual potential parents.
                          _potentialParents = params.locations
                              .where(
                                (loc) => validParentTypes.contains(loc.type),
                              )
                              .toList();
                        }
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a type' : null,
                  ),
                  const SizedBox(height: 24),
                  // --- Parent Location Dropdown (conditionally shown) ---
                  if (_potentialParents.isNotEmpty)
                    DropdownButtonFormField<Location>(
                      value: _selectedParent,
                      // The label is now dynamic.
                      decoration: const InputDecoration(
                        labelText: 'Part of which Location?',
                      ),
                      items: _potentialParents
                          .map(
                            (parent) => DropdownMenuItem(
                              value: parent,
                              child: Text(parent.name),
                            ),
                          )
                          .toList(),
                      onChanged: (parent) =>
                          setState(() => _selectedParent = parent),
                      validator: (value) => value == null
                          ? 'Please select a parent location'
                          : null,
                    ),
                  if (_potentialParents.isNotEmpty) const SizedBox(height: 24),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _nameControllers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return TextFormField(
                        controller: _nameControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Location Name #${index + 1}',
                          // Add a remove button for all fields except the first one.
                          suffixIcon: index > 0
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _removeLocationField(index),
                                )
                              : null,
                        ),
                        validator: (value) {
                          // Validation is optional for all but the first field.
                          if (index == 0 && (value?.trim().isEmpty ?? true)) {
                            return 'At least one location name is required';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _addLocationField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Location'),
                  ),

                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      onPressed: locationsControllerState.isLoading
                          ? null
                          : _saveLocations,
                      child: locationsControllerState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Location(s)'),
                    ),
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
