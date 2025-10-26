// lib/src/features/farm_os/farm_details/presentation/screens/farm_details_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/data/farm_repository.dart';
import 'package:liminetic/src/features/farm_os/domain/farm_model.dart';

part 'farm_details_screen.g.dart';

/// A provider that fetches the details for a *single*, specific farm.
/// The `.family` modifier allows us to pass in the `farmId`.
@riverpod
Future<Farm?> farmDetails(Ref ref, String farmId) {
  final farmRepo = ref.watch(farmRepositoryProvider);
  return farmRepo.getFarm(farmId);
}

/// Controller for updating a specific farm's details.
@riverpod
class FarmDetailsController extends _$FarmDetailsController {
  @override
  FutureOr<void> build() {}

  Future<void> updateFarmDetails({
    required String farmId,
    required String farmName,
  }) async {
    final farmRepo = ref.read(farmRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => farmRepo.updateFarmDetails(farmId: farmId, farmName: farmName),
    );
  }
}

/// A screen where users can edit a specific farm's details.
class FarmDetailsScreen extends ConsumerStatefulWidget {
  final String farmId;
  const FarmDetailsScreen({super.key, required this.farmId});

  @override
  ConsumerState<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends ConsumerState<FarmDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();

  @override
  void dispose() {
    _farmNameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(farmDetailsControllerProvider.notifier)
          .updateFarmDetails(
            farmId: widget.farmId,
            farmName: _farmNameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider for this specific farm's details.
    final farmDetailsAsync = ref.watch(farmDetailsProvider(widget.farmId));

    // Listen to the controller for success/error feedback.
    ref.listen<AsyncValue<void>>(farmDetailsControllerProvider, (_, state) {
      if (!state.isLoading && !state.hasError) {
        // Invalidate providers to refetch data across the app.
        ref.invalidate(sessionProvider);
        ref.invalidate(farmDetailsProvider(widget.farmId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Farm details updated!')));
        context.pop();
      }
      // ... error handling
    });

    final controllerState = ref.watch(farmDetailsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Farm Details')),
      body: farmDetailsAsync.when(
        data: (farm) {
          if (farm == null) {
            return const Center(child: Text('Farm not found.'));
          }
          // Set the controller's text only if it hasn't been set yet.
          if (_farmNameController.text.isEmpty) {
            _farmNameController.text = farm.farmName;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _farmNameController,
                    decoration: const InputDecoration(labelText: 'Farm Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a farm name' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: controllerState.isLoading ? null : _saveChanges,
                    child: controllerState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) =>
            const Center(child: Text('Could not load farm details.')),
      ),
    );
  }
}
