// lib/src/features/auth/presentation/profile_controller.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/data/auth_repository.dart';

// This directive links this file to the code that will be generated.
part 'profile_controller.g.dart';

/// A controller for handling user profile update actions.
///
/// The `@riverpod` annotation automatically creates an `AutoDisposeAsyncNotifierProvider`
/// named `profileControllerProvider` that can be accessed throughout the app.
@riverpod
class ProfileController extends _$ProfileController {
  /// The `build` method is required by the Notifier. Since this controller
  /// only performs actions, it doesn't need to initialize with a state.
  @override
  FutureOr<void> build() {
    // No-op. This controller is for executing methods, not for holding a persistent state.
  }

  /// Updates the current user's username in Firestore.
  Future<void> updateProfile({
    required String uid,
    required String username,
  }) async {
    // Read the repository to access its data-handling methods.
    final authRepo = ref.read(authRepositoryProvider);

    // Set the state to loading to show feedback in the UI.
    state = const AsyncLoading();

    // Use AsyncValue.guard to automatically handle success and error states.
    // If the repository method succeeds, the state becomes AsyncData(null).
    // If it throws an error, the state becomes AsyncError(error).
    state = await AsyncValue.guard(() async {
      await authRepo.updateUserProfile(uid: uid, username: username);
    });
  }
}
