// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_location_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The addLocationFormParamsProvider needs to know about active modules.

@ProviderFor(addLocationFormParams)
const addLocationFormParamsProvider = AddLocationFormParamsProvider._();

/// The addLocationFormParamsProvider needs to know about active modules.

final class AddLocationFormParamsProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocationFormParams>,
          LocationFormParams,
          FutureOr<LocationFormParams>
        >
    with
        $FutureModifier<LocationFormParams>,
        $FutureProvider<LocationFormParams> {
  /// The addLocationFormParamsProvider needs to know about active modules.
  const AddLocationFormParamsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addLocationFormParamsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addLocationFormParamsHash();

  @$internal
  @override
  $FutureProviderElement<LocationFormParams> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LocationFormParams> create(Ref ref) {
    return addLocationFormParams(ref);
  }
}

String _$addLocationFormParamsHash() =>
    r'e10b6ebdb50ba7cca9fa8f6f2e56f92ba1b2979c';
