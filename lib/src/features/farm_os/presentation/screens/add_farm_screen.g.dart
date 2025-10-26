// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_farm_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for creating a new farm by an existing user.
/// The `@riverpod` annotation will generate the `addFarmControllerProvider`.

@ProviderFor(AddFarmController)
const addFarmControllerProvider = AddFarmControllerProvider._();

/// Controller for creating a new farm by an existing user.
/// The `@riverpod` annotation will generate the `addFarmControllerProvider`.
final class AddFarmControllerProvider
    extends $AsyncNotifierProvider<AddFarmController, void> {
  /// Controller for creating a new farm by an existing user.
  /// The `@riverpod` annotation will generate the `addFarmControllerProvider`.
  const AddFarmControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addFarmControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addFarmControllerHash();

  @$internal
  @override
  AddFarmController create() => AddFarmController();
}

String _$addFarmControllerHash() => r'7509777afde9e0defffdb3164530404a763dd586';

/// Controller for creating a new farm by an existing user.
/// The `@riverpod` annotation will generate the `addFarmControllerProvider`.

abstract class _$AddFarmController extends $AsyncNotifier<void> {
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
