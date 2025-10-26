// lib/src/features/auth/presentation/auth_controller.dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart'; // Make sure this is imported
import 'package:liminetic/src/features/auth/data/auth_repository.dart';

// Step 1: Add the part directive. This will show an error until the file is generated.
part 'auth_controller.g.dart'; // Step 2: Add the @riverpod annotation. This replaces your old manual provider.

@riverpod
// Step 3: Change the class to extend the generated name ( _$ClassName )
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // No initial state needed.
  }

  /// Signs up a new user and creates their first farm.
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String farmName,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => authRepository.signUpAndCreateFarm(
        email: email,
        password: password,
        username: username,
        farmName: farmName,
      ),
    );
  }

  /// Signs in a user with their login identifier and password.
  Future<void> signIn({
    required String loginIdentifier,
    required String password,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => authRepository.signIn(
        loginIdentifier: loginIdentifier,
        password: password,
      ),
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(authRepository.signOut);
  }
}
