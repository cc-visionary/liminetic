// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logbook_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to hold the current filter and search query state.

@ProviderFor(LogbookFilterNotifier)
const logbookFilterProvider = LogbookFilterNotifierProvider._();

/// Provider to hold the current filter and search query state.
final class LogbookFilterNotifierProvider
    extends $NotifierProvider<LogbookFilterNotifier, LogbookFilter> {
  /// Provider to hold the current filter and search query state.
  const LogbookFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logbookFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logbookFilterNotifierHash();

  @$internal
  @override
  LogbookFilterNotifier create() => LogbookFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogbookFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogbookFilter>(value),
    );
  }
}

String _$logbookFilterNotifierHash() =>
    r'517e3e5319d3b1f491105e614b5a5c559c7396cc';

/// Provider to hold the current filter and search query state.

abstract class _$LogbookFilterNotifier extends $Notifier<LogbookFilter> {
  LogbookFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LogbookFilter, LogbookFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LogbookFilter, LogbookFilter>,
              LogbookFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// A base provider that fetches the raw, unfiltered stream of all logs.

@ProviderFor(rawLogbookStream)
const rawLogbookStreamProvider = RawLogbookStreamProvider._();

/// A base provider that fetches the raw, unfiltered stream of all logs.

final class RawLogbookStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LogEntry>>,
          List<LogEntry>,
          Stream<List<LogEntry>>
        >
    with $FutureModifier<List<LogEntry>>, $StreamProvider<List<LogEntry>> {
  /// A base provider that fetches the raw, unfiltered stream of all logs.
  const RawLogbookStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rawLogbookStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rawLogbookStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<LogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LogEntry>> create(Ref ref) {
    return rawLogbookStream(ref);
  }
}

String _$rawLogbookStreamHash() => r'1166fd26736685a6fe2f04f1c210638b2818ce44';

/// A derived provider that filters and searches the raw list of logs.
/// The UI will watch this provider to display the final, visible list.

@ProviderFor(filteredLogbook)
const filteredLogbookProvider = FilteredLogbookProvider._();

/// A derived provider that filters and searches the raw list of logs.
/// The UI will watch this provider to display the final, visible list.

final class FilteredLogbookProvider
    extends $FunctionalProvider<List<LogEntry>, List<LogEntry>, List<LogEntry>>
    with $Provider<List<LogEntry>> {
  /// A derived provider that filters and searches the raw list of logs.
  /// The UI will watch this provider to display the final, visible list.
  const FilteredLogbookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredLogbookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredLogbookHash();

  @$internal
  @override
  $ProviderElement<List<LogEntry>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<LogEntry> create(Ref ref) {
    return filteredLogbook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LogEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LogEntry>>(value),
    );
  }
}

String _$filteredLogbookHash() => r'8c88d8755d0d8b0dd4ae18446aa2b0bbc4d25dfe';

/// Controller for handling actions related to the logbook.

@ProviderFor(LogbookController)
const logbookControllerProvider = LogbookControllerProvider._();

/// Controller for handling actions related to the logbook.
final class LogbookControllerProvider
    extends $AsyncNotifierProvider<LogbookController, void> {
  /// Controller for handling actions related to the logbook.
  const LogbookControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logbookControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logbookControllerHash();

  @$internal
  @override
  LogbookController create() => LogbookController();
}

String _$logbookControllerHash() => r'3bb2ccc5df7f5b6a74e5988d12a45e7c68abfa1a';

/// Controller for handling actions related to the logbook.

abstract class _$LogbookController extends $AsyncNotifier<void> {
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
