// lib/src/features/farm_os/modules/presentation/controllers/modules_controller.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/data/farm_repository.dart';

part 'modules_controller.g.dart';

/// Controller for handling actions related to farm module management.
@riverpod
class ModulesController extends _$ModulesController {
  @override
  FutureOr<void> build() {
    // No initial state needed for this action controller.
  }

  /// Updates the list of active modules for the current farm.
  Future<void> updateModules(List<String> newModuleList) async {
    final farmRepo = ref.read(farmRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;

    if (farmId == null) {
      throw Exception('Cannot update modules: No active farm found.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => farmRepo.updateActiveModules(
        farmId: farmId,
        activeModules: newModuleList,
      ),
    );
  }
}
