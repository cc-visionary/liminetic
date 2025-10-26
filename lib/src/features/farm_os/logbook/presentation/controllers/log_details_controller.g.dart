// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_details_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A provider to resolve an assignee's ID to their username.
/// The `.family` modifier allows us to pass in the ID.

@ProviderFor(assigneeName)
const assigneeNameProvider = AssigneeNameFamily._();

/// A provider to resolve an assignee's ID to their username.
/// The `.family` modifier allows us to pass in the ID.

final class AssigneeNameProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// A provider to resolve an assignee's ID to their username.
  /// The `.family` modifier allows us to pass in the ID.
  const AssigneeNameProvider._({
    required AssigneeNameFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'assigneeNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assigneeNameHash();

  @override
  String toString() {
    return r'assigneeNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String?;
    return assigneeName(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AssigneeNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assigneeNameHash() => r'a7067f258175af87ff4e8a5a9f3a3688a3fa956e';

/// A provider to resolve an assignee's ID to their username.
/// The `.family` modifier allows us to pass in the ID.

final class AssigneeNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String?> {
  const AssigneeNameFamily._()
    : super(
        retry: null,
        name: r'assigneeNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A provider to resolve an assignee's ID to their username.
  /// The `.family` modifier allows us to pass in the ID.

  AssigneeNameProvider call(String? assigneeId) =>
      AssigneeNameProvider._(argument: assigneeId, from: this);

  @override
  String toString() => r'assigneeNameProvider';
}

/// A provider that resolves a list of location IDs to a comma-separated string of names.

@ProviderFor(locationNames)
const locationNamesProvider = LocationNamesFamily._();

/// A provider that resolves a list of location IDs to a comma-separated string of names.

final class LocationNamesProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// A provider that resolves a list of location IDs to a comma-separated string of names.
  const LocationNamesProvider._({
    required LocationNamesFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'locationNamesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$locationNamesHash();

  @override
  String toString() {
    return r'locationNamesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as List<String>;
    return locationNames(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LocationNamesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$locationNamesHash() => r'6d5dc0cb4a603e8f5ff9c594bc24077c50990442';

/// A provider that resolves a list of location IDs to a comma-separated string of names.

final class LocationNamesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, List<String>> {
  const LocationNamesFamily._()
    : super(
        retry: null,
        name: r'locationNamesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A provider that resolves a list of location IDs to a comma-separated string of names.

  LocationNamesProvider call(List<String> locationIds) =>
      LocationNamesProvider._(argument: locationIds, from: this);

  @override
  String toString() => r'locationNamesProvider';
}
