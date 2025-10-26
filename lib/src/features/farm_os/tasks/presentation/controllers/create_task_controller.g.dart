// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A provider that fetches all team members and locations to populate the
/// dropdown menus in the 'Create Task' screen.

@ProviderFor(createTaskFormParams)
const createTaskFormParamsProvider = CreateTaskFormParamsProvider._();

/// A provider that fetches all team members and locations to populate the
/// dropdown menus in the 'Create Task' screen.

final class CreateTaskFormParamsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreateTaskFormParams>,
          CreateTaskFormParams,
          FutureOr<CreateTaskFormParams>
        >
    with
        $FutureModifier<CreateTaskFormParams>,
        $FutureProvider<CreateTaskFormParams> {
  /// A provider that fetches all team members and locations to populate the
  /// dropdown menus in the 'Create Task' screen.
  const CreateTaskFormParamsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createTaskFormParamsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createTaskFormParamsHash();

  @$internal
  @override
  $FutureProviderElement<CreateTaskFormParams> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreateTaskFormParams> create(Ref ref) {
    return createTaskFormParams(ref);
  }
}

String _$createTaskFormParamsHash() =>
    r'b437d110eb513518e8368eeb8a08d7ee8c8ee9e3';
