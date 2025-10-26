// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modules_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for handling actions related to farm module management.

@ProviderFor(ModulesController)
const modulesControllerProvider = ModulesControllerProvider._();

/// Controller for handling actions related to farm module management.
final class ModulesControllerProvider
    extends $AsyncNotifierProvider<ModulesController, void> {
  /// Controller for handling actions related to farm module management.
  const ModulesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modulesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modulesControllerHash();

  @$internal
  @override
  ModulesController create() => ModulesController();
}

String _$modulesControllerHash() => r'a4fe514a628a610c2003d9a33e86bca3f9f873b8';

/// Controller for handling actions related to farm module management.

abstract class _$ModulesController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
