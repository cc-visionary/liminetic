// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_details_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A provider to resolve an assignee's ID to their username.

@ProviderFor(assigneeName)
const assigneeNameProvider = AssigneeNameFamily._();

/// A provider to resolve an assignee's ID to their username.

final class AssigneeNameProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// A provider to resolve an assignee's ID to their username.
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

  AssigneeNameProvider call(String? assigneeId) =>
      AssigneeNameProvider._(argument: assigneeId, from: this);

  @override
  String toString() => r'assigneeNameProvider';
}

/// A provider to resolve a location's ID to its name.

@ProviderFor(locationName)
const locationNameProvider = LocationNameFamily._();

/// A provider to resolve a location's ID to its name.

final class LocationNameProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// A provider to resolve a location's ID to its name.
  const LocationNameProvider._({
    required LocationNameFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'locationNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$locationNameHash();

  @override
  String toString() {
    return r'locationNameProvider'
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
    return locationName(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LocationNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$locationNameHash() => r'0f916675144117dd3796e8f6e141a73253419848';

/// A provider to resolve a location's ID to its name.

final class LocationNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String?> {
  const LocationNameFamily._()
    : super(
        retry: null,
        name: r'locationNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A provider to resolve a location's ID to its name.

  LocationNameProvider call(String? locationId) =>
      LocationNameProvider._(argument: locationId, from: this);

  @override
  String toString() => r'locationNameProvider';
}
