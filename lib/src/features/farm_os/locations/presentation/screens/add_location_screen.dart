// lib/src/features/farm_os/locations/presentation/screens/add_location_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_template_model.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/add_location_controller.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';

class AddLocationScreen extends ConsumerStatefulWidget {
  const AddLocationScreen({super.key});

  @override
  ConsumerState<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  LocationTemplate? _selectedTemplate;
  Location? _selectedParent;
  List<Location> _potentialParents = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveLocation() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(locationsControllerProvider.notifier)
          .addLocation(
            name: _nameController.text.trim(),
            type: _selectedTemplate!.name,
            level: _selectedTemplate!.level,
            parentLocationId: _selectedParent?.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formParamsAsync = ref.watch(addLocationFormParamsProvider);
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
          final availableTemplates = params.allTemplates.where((template) {
            // Rule 1: Always allow creating top-level (Level 1) locations.
            if (template.level == 1) {
              return true;
            }

            // Rule 2: For higher levels, only allow creation if a valid parent already exists on the farm.
            // First, find all the *types* of locations that can be a parent to this template.
            final validParentTypes = params.allTemplates
                .where(
                  (parentTemplate) =>
                      parentTemplate.possibleChildren.contains(template.name),
                )
                .map((pt) => pt.name)
                .toSet(); // Use a Set for efficient lookup.

            // Then, check if any of the *existing* farm locations match one of those parent types.
            final aValidParentExistsOnFarm = params.allLocations.any(
              (existingLocation) =>
                  validParentTypes.contains(existingLocation.type),
            );

            return aValidParentExistsOnFarm;
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
                          final validParentTypes = params.allTemplates
                              .where(
                                (parentTemplate) => parentTemplate
                                    .possibleChildren
                                    .contains(template.name),
                              )
                              .map((pt) => pt.name)
                              .toList();

                          // 2. Filter the list of EXISTING locations to find actual potential parents.
                          _potentialParents = params.allLocations
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Location Name',
                      hintText: 'e.g., Pen #12',
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Please enter a name'
                        : null,
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
                  if (_potentialParents.isNotEmpty) const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: locationsControllerState.isLoading
                        ? null
                        : _saveLocation,
                    child: locationsControllerState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Location'),
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
