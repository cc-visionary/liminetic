// lib/src/features/auth/presentation/controllers/session_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/data/auth_repository.dart';

part 'session_controller.g.dart';

/// A controller for handling user session actions, such as switching farms.
@riverpod
class SessionController extends _$SessionController {
  @override
  FutureOr<void> build() {
    // No initial state needed for an action controller.
  }

  /// Changes the user's active farm in Firestore.
  ///
  /// The UI will react automatically because the `sessionProvider` will be
  /// invalidated and will refetch the new state.
  Future<void> switchActiveFarm(String newFarmId) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      throw Exception('User must be logged in to switch farms.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'activeFarmId': newFarmId},
      );
    });
  }
}
