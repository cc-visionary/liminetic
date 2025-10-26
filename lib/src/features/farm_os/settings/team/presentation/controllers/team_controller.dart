// lib/src/features/farm_os/team/presentation/controllers/team_controller.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/data/auth_repository.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/data/farm_repository.dart';
import 'package:liminetic/src/features/farm_os/settings/team/domain/farm_member_model.dart';

part 'team_controller.g.dart';

/// Provider to get a real-time stream of farm members for the active farm.
@riverpod
Stream<List<FarmMember>> team(
  Ref ref,
) {
  final farmRepo = ref.watch(farmRepositoryProvider);
  final farmId = ref.watch(sessionProvider).value?.activeFarm?.id;

  if (farmId == null) {
    return Stream.value([]);
  }
  return farmRepo.getFarmMembers(farmId);
}

/// Controller for handling actions related to the team, like adding members.
@riverpod
class TeamController extends _$TeamController {
  @override
  FutureOr<void> build() {
    // No initial state needed.
  }

  /// Adds a new sub-user member to the currently active farm.
  Future<void> addMember({
    required String username,
    required String password,
    required String role,
  }) async {
    final authRepo = ref.read(authRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;

    if (farmId == null) {
      throw Exception('Cannot add member without an active farm.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => authRepo.createSubUser(
        username: username,
        password: password,
        farmId: farmId,
        role: role,
        permissions: {},
      ),
    );
  }
}
