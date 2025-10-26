// lib/src/features/farm_os/locations/presentation/screens/location_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';

/// A screen to view, edit, and delete a specific location's details.
class LocationDetailsScreen extends ConsumerStatefulWidget {
  final Location location;
  const LocationDetailsScreen({super.key, required this.location});

  @override
  ConsumerState<LocationDetailsScreen> createState() =>
      _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends ConsumerState<LocationDetailsScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Triggers the update logic in the controller.
  void _updateLocation() {
    if (_nameController.text.trim().isEmpty) return;
    ref
        .read(locationsControllerProvider.notifier)
        .updateLocation(
          locationId: widget.location.id,
          newName: _nameController.text.trim(),
        );
  }

  /// Shows a confirmation dialog and triggers the delete logic.
  Future<void> _deleteLocation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location?'),
        content: Text(
          'Are you sure you want to delete "${widget.location.name}"? This action cannot be undone.',
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
      ref
          .read(locationsControllerProvider.notifier)
          .deleteLocation(widget.location.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(locationsControllerProvider, (previous, next) {
      if ((previous?.isLoading ?? false) && !next.isLoading && !next.hasError) {
        ref.invalidate(rawLocationsStreamProvider);
        context.pop(); // Go back to the list screen on success
      }
      // ... error handling
    });

    final controllerState = ref.watch(locationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.location.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Location Name'),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Location Type',
                border: InputBorder.none,
                enabled: false,
              ),
              child: Text(
                widget.location.type,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controllerState.isLoading ? null : _updateLocation,
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: controllerState.isLoading ? null : _deleteLocation,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete Location'),
            ),
          ],
        ),
      ),
    );
  }
}
