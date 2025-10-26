// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A controller for handling user profile update actions.
///
/// The `@riverpod` annotation automatically creates an `AutoDisposeAsyncNotifierProvider`
/// named `profileControllerProvider` that can be accessed throughout the app.

@ProviderFor(ProfileController)
const profileControllerProvider = ProfileControllerProvider._();

/// A controller for handling user profile update actions.
///
/// The `@riverpod` annotation automatically creates an `AutoDisposeAsyncNotifierProvider`
/// named `profileControllerProvider` that can be accessed throughout the app.
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, void> {
  /// A controller for handling user profile update actions.
  ///
  /// The `@riverpod` annotation automatically creates an `AutoDisposeAsyncNotifierProvider`
  /// named `profileControllerProvider` that can be accessed throughout the app.
  const ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'03d5f3333c43e281bdb42606364862ea19679a06';

/// A controller for handling user profile update actions.
///
/// The `@riverpod` annotation automatically creates an `AutoDisposeAsyncNotifierProvider`
/// named `profileControllerProvider` that can be accessed throughout the app.

abstract class _$ProfileController extends $AsyncNotifier<void> {
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
