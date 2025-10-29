// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_details_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A provider that fetches and filters the logbook to find all usage history
/// for a specific inventory item.
///
/// This is now a synchronous provider. It watches the raw stream's
/// state and returns a filtered list of logs only when the data is available.

@ProviderFor(itemUsageHistory)
const itemUsageHistoryProvider = ItemUsageHistoryFamily._();

/// A provider that fetches and filters the logbook to find all usage history
/// for a specific inventory item.
///
/// This is now a synchronous provider. It watches the raw stream's
/// state and returns a filtered list of logs only when the data is available.

final class ItemUsageHistoryProvider
    extends $FunctionalProvider<List<LogEntry>, List<LogEntry>, List<LogEntry>>
    with $Provider<List<LogEntry>> {
  /// A provider that fetches and filters the logbook to find all usage history
  /// for a specific inventory item.
  ///
  /// This is now a synchronous provider. It watches the raw stream's
  /// state and returns a filtered list of logs only when the data is available.
  const ItemUsageHistoryProvider._({
    required ItemUsageHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemUsageHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemUsageHistoryHash();

  @override
  String toString() {
    return r'itemUsageHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<LogEntry>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<LogEntry> create(Ref ref) {
    final argument = this.argument as String;
    return itemUsageHistory(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LogEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LogEntry>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemUsageHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemUsageHistoryHash() => r'562b39e0fa9a81ed3ea94a4bca45d0b78e885eac';

/// A provider that fetches and filters the logbook to find all usage history
/// for a specific inventory item.
///
/// This is now a synchronous provider. It watches the raw stream's
/// state and returns a filtered list of logs only when the data is available.

final class ItemUsageHistoryFamily extends $Family
    with $FunctionalFamilyOverride<List<LogEntry>, String> {
  const ItemUsageHistoryFamily._()
    : super(
        retry: null,
        name: r'itemUsageHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A provider that fetches and filters the logbook to find all usage history
  /// for a specific inventory item.
  ///
  /// This is now a synchronous provider. It watches the raw stream's
  /// state and returns a filtered list of logs only when the data is available.

  ItemUsageHistoryProvider call(String itemId) =>
      ItemUsageHistoryProvider._(argument: itemId, from: this);

  @override
  String toString() => r'itemUsageHistoryProvider';
}
