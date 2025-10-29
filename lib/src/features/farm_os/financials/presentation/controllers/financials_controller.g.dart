// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financials_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A provider that supplies a real-time stream of all financial transactions.

@ProviderFor(financials)
const financialsProvider = FinancialsProvider._();

/// A provider that supplies a real-time stream of all financial transactions.

final class FinancialsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FinancialTransaction>>,
          List<FinancialTransaction>,
          Stream<List<FinancialTransaction>>
        >
    with
        $FutureModifier<List<FinancialTransaction>>,
        $StreamProvider<List<FinancialTransaction>> {
  /// A provider that supplies a real-time stream of all financial transactions.
  const FinancialsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financialsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financialsHash();

  @$internal
  @override
  $StreamProviderElement<List<FinancialTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FinancialTransaction>> create(Ref ref) {
    return financials(ref);
  }
}

String _$financialsHash() => r'140391b5cb789f7cbc75b37f47a75cbb51761dbe';

/// A derived provider that calculates the financial summary from the list of transactions.
///
/// The UI will watch this provider. It automatically recalculates whenever the
/// list of transactions changes.

@ProviderFor(financialSummary)
const financialSummaryProvider = FinancialSummaryProvider._();

/// A derived provider that calculates the financial summary from the list of transactions.
///
/// The UI will watch this provider. It automatically recalculates whenever the
/// list of transactions changes.

final class FinancialSummaryProvider
    extends
        $FunctionalProvider<
          FinancialSummary,
          FinancialSummary,
          FinancialSummary
        >
    with $Provider<FinancialSummary> {
  /// A derived provider that calculates the financial summary from the list of transactions.
  ///
  /// The UI will watch this provider. It automatically recalculates whenever the
  /// list of transactions changes.
  const FinancialSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financialSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financialSummaryHash();

  @$internal
  @override
  $ProviderElement<FinancialSummary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FinancialSummary create(Ref ref) {
    return financialSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinancialSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinancialSummary>(value),
    );
  }
}

String _$financialSummaryHash() => r'c5416d1cbc1bd319f290cda10bb5ca6139bb0e6a';

/// A controller for handling actions related to financial transactions.

@ProviderFor(FinancialsController)
const financialsControllerProvider = FinancialsControllerProvider._();

/// A controller for handling actions related to financial transactions.
final class FinancialsControllerProvider
    extends $AsyncNotifierProvider<FinancialsController, void> {
  /// A controller for handling actions related to financial transactions.
  const FinancialsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financialsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financialsControllerHash();

  @$internal
  @override
  FinancialsController create() => FinancialsController();
}

String _$financialsControllerHash() =>
    r'44f47436d3dac94bd598a849d09fe54f70bbd8a9';

/// A controller for handling actions related to financial transactions.

abstract class _$FinancialsController extends $AsyncNotifier<void> {
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
