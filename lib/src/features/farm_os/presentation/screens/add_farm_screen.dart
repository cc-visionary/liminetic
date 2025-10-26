// lib/src/features/farm_os/presentation/screens/add_farm_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/data/auth_repository.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';

// This directive links the file to its generated counterpart.
part 'add_farm_screen.g.dart';

/// Controller for creating a new farm by an existing user.
/// The `@riverpod` annotation will generate the `addFarmControllerProvider`.
@riverpod
class AddFarmController extends _$AddFarmController {
  @override
  FutureOr<void> build() {
    // This controller is for actions, so no initial state is needed.
  }

  /// Executes the logic to create a new farm document and associate it with the current user.
  Future<void> createFarm(String farmName) async {
    final authRepo = ref.read(authRepositoryProvider);
    // Safely access the current user's ID from the session provider.
    final ownerId = ref.read(sessionProvider).value?.appUser?.uid;

    if (ownerId == null) {
      throw Exception('Cannot create farm: user not logged in.');
    }

    // Set the state to loading before the operation.
    state = const AsyncLoading();
    // Use AsyncValue.guard to handle potential errors from the repository.
    state = await AsyncValue.guard(
      () => authRepo.createNewFarm(farmName: farmName, ownerId: ownerId),
    );
  }
}

/// A screen for an existing, logged-in user to create an additional farm.
class AddFarmScreen extends ConsumerStatefulWidget {
  const AddFarmScreen({super.key});

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _farmNameController = TextEditingController();

  /// Validates the input and triggers the createFarm method in the controller.
  void _createFarm() {
    if (_farmNameController.text.trim().isNotEmpty) {
      ref
          .read(addFarmControllerProvider.notifier)
          .createFarm(_farmNameController.text.trim());
    }
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider's state to handle side-effects like navigation
    // or showing snackbars upon completion or error.
    ref.listen<AsyncValue<void>>(addFarmControllerProvider, (_, state) {
      // On success (no error and not loading), refresh the user's session
      // to fetch the new farm list and navigate back home.
      if (!state.isLoading && !state.hasError) {
        ref.invalidate(sessionProvider);
        context.go('/home');
      }
      // If an error occurs, show it in a SnackBar.
      if (state.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    });

    // Watch the provider's state to update the UI (e.g., disable the button).
    final state = ref.watch(addFarmControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Farm')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _farmNameController,
              decoration: const InputDecoration(labelText: 'Farm Name'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              // Disable the button while the creation is in progress.
              onPressed: state.isLoading ? null : _createFarm,
              child: state.isLoading
                  // Show a loading indicator inside the button.
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Create Farm'),
            ),
          ],
        ),
      ),
    );
  }
}
