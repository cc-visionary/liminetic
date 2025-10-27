// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_form_params_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A universal provider that fetches all common form parameters in a single,
/// efficient operation.
///
/// This replaces multiple redundant providers and serves as the single source
/// of truth for data needed in forms.

@ProviderFor(generalFormParams)
const generalFormParamsProvider = GeneralFormParamsProvider._();

/// A universal provider that fetches all common form parameters in a single,
/// efficient operation.
///
/// This replaces multiple redundant providers and serves as the single source
/// of truth for data needed in forms.

final class GeneralFormParamsProvider
    extends
        $FunctionalProvider<
          AsyncValue<GeneralFormParams>,
          GeneralFormParams,
          FutureOr<GeneralFormParams>
        >
    with
        $FutureModifier<GeneralFormParams>,
        $FutureProvider<GeneralFormParams> {
  /// A universal provider that fetches all common form parameters in a single,
  /// efficient operation.
  ///
  /// This replaces multiple redundant providers and serves as the single source
  /// of truth for data needed in forms.
  const GeneralFormParamsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generalFormParamsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generalFormParamsHash();

  @$internal
  @override
  $FutureProviderElement<GeneralFormParams> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GeneralFormParams> create(Ref ref) {
    return generalFormParams(ref);
  }
}

String _$generalFormParamsHash() => r'eff60d6fdf9f1dccf8a44f89e5c43b7f56133464';
