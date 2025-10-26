// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_details_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A provider that fetches the details for a *single*, specific farm.
/// The `.family` modifier allows us to pass in the `farmId`.

@ProviderFor(farmDetails)
const farmDetailsProvider = FarmDetailsFamily._();

/// A provider that fetches the details for a *single*, specific farm.
/// The `.family` modifier allows us to pass in the `farmId`.

final class FarmDetailsProvider
    extends $FunctionalProvider<AsyncValue<Farm?>, Farm?, FutureOr<Farm?>>
    with $FutureModifier<Farm?>, $FutureProvider<Farm?> {
  /// A provider that fetches the details for a *single*, specific farm.
  /// The `.family` modifier allows us to pass in the `farmId`.
  const FarmDetailsProvider._({
    required FarmDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'farmDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$farmDetailsHash();

  @override
  String toString() {
    return r'farmDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Farm?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Farm?> create(Ref ref) {
    final argument = this.argument as String;
    return farmDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FarmDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$farmDetailsHash() => r'9a05a4f9e7a0e16a647c194938d319fa308aaae7';

/// A provider that fetches the details for a *single*, specific farm.
/// The `.family` modifier allows us to pass in the `farmId`.

final class FarmDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Farm?>, String> {
  const FarmDetailsFamily._()
    : super(
        retry: null,
        name: r'farmDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A provider that fetches the details for a *single*, specific farm.
  /// The `.family` modifier allows us to pass in the `farmId`.

  FarmDetailsProvider call(String farmId) =>
      FarmDetailsProvider._(argument: farmId, from: this);

  @override
  String toString() => r'farmDetailsProvider';
}

/// Controller for updating a specific farm's details.

@ProviderFor(FarmDetailsController)
const farmDetailsControllerProvider = FarmDetailsControllerProvider._();

/// Controller for updating a specific farm's details.
final class FarmDetailsControllerProvider
    extends $AsyncNotifierProvider<FarmDetailsController, void> {
  /// Controller for updating a specific farm's details.
  const FarmDetailsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'farmDetailsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$farmDetailsControllerHash();

  @$internal
  @override
  FarmDetailsController create() => FarmDetailsController();
}

String _$farmDetailsControllerHash() =>
    r'36eb2017857073e49144e935937523d3534409db';

/// Controller for updating a specific farm's details.

abstract class _$FarmDetailsController extends $AsyncNotifier<void> {
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
