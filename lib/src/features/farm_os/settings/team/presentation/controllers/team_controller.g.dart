// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to get a real-time stream of farm members for the active farm.

@ProviderFor(team)
const teamProvider = TeamProvider._();

/// Provider to get a real-time stream of farm members for the active farm.

final class TeamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FarmMember>>,
          List<FarmMember>,
          Stream<List<FarmMember>>
        >
    with $FutureModifier<List<FarmMember>>, $StreamProvider<List<FarmMember>> {
  /// Provider to get a real-time stream of farm members for the active farm.
  const TeamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamHash();

  @$internal
  @override
  $StreamProviderElement<List<FarmMember>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FarmMember>> create(Ref ref) {
    return team(ref);
  }
}

String _$teamHash() => r'24954928e9355a63ce5914ca1e056c796b3a504e';

/// Controller for handling actions related to the team, like adding members.

@ProviderFor(TeamController)
const teamControllerProvider = TeamControllerProvider._();

/// Controller for handling actions related to the team, like adding members.
final class TeamControllerProvider
    extends $AsyncNotifierProvider<TeamController, void> {
  /// Controller for handling actions related to the team, like adding members.
  const TeamControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamControllerHash();

  @$internal
  @override
  TeamController create() => TeamController();
}

String _$teamControllerHash() => r'28fcecfb4503bae98f69cde6a2afd38887d3593f';

/// Controller for handling actions related to the team, like adding members.

abstract class _$TeamController extends $AsyncNotifier<void> {
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
