// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A simple provider to hold the currently selected filter state.
/// The UI will update this provider when the user taps a filter chip.

@ProviderFor(TasksFilter)
const tasksFilterProvider = TasksFilterProvider._();

/// A simple provider to hold the currently selected filter state.
/// The UI will update this provider when the user taps a filter chip.
final class TasksFilterProvider
    extends $NotifierProvider<TasksFilter, TaskFilter> {
  /// A simple provider to hold the currently selected filter state.
  /// The UI will update this provider when the user taps a filter chip.
  const TasksFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksFilterHash();

  @$internal
  @override
  TasksFilter create() => TasksFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskFilter>(value),
    );
  }
}

String _$tasksFilterHash() => r'3f1288447136c82f607839128a7cb52ead40980d';

/// A simple provider to hold the currently selected filter state.
/// The UI will update this provider when the user taps a filter chip.

abstract class _$TasksFilter extends $Notifier<TaskFilter> {
  TaskFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TaskFilter, TaskFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskFilter, TaskFilter>,
              TaskFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// A base provider that fetches a raw, unfiltered stream of all tasks for the farm.

@ProviderFor(rawTasksStream)
const rawTasksStreamProvider = RawTasksStreamProvider._();

/// A base provider that fetches a raw, unfiltered stream of all tasks for the farm.

final class RawTasksStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// A base provider that fetches a raw, unfiltered stream of all tasks for the farm.
  const RawTasksStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rawTasksStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rawTasksStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return rawTasksStream(ref);
  }
}

String _$rawTasksStreamHash() => r'933404019a0205ab3ecf8374bdda8eea8d89b209';

/// A derived provider that filters the raw list of tasks based on the selected filter.
/// The UI will watch this provider to display the final, filtered list.

@ProviderFor(filteredTasks)
const filteredTasksProvider = FilteredTasksProvider._();

/// A derived provider that filters the raw list of tasks based on the selected filter.
/// The UI will watch this provider to display the final, filtered list.

final class FilteredTasksProvider
    extends $FunctionalProvider<List<Task>, List<Task>, List<Task>>
    with $Provider<List<Task>> {
  /// A derived provider that filters the raw list of tasks based on the selected filter.
  /// The UI will watch this provider to display the final, filtered list.
  const FilteredTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTasksHash();

  @$internal
  @override
  $ProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Task> create(Ref ref) {
    return filteredTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Task> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Task>>(value),
    );
  }
}

String _$filteredTasksHash() => r'63c39bb3ef879b2009edafc0ff580037505510a4';

/// A controller for handling actions related to tasks.

@ProviderFor(TasksController)
const tasksControllerProvider = TasksControllerProvider._();

/// A controller for handling actions related to tasks.
final class TasksControllerProvider
    extends $AsyncNotifierProvider<TasksController, void> {
  /// A controller for handling actions related to tasks.
  const TasksControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksControllerHash();

  @$internal
  @override
  TasksController create() => TasksController();
}

String _$tasksControllerHash() => r'8bd859ea50cf684f02dd0d5f125809367f90c0da';

/// A controller for handling actions related to tasks.

abstract class _$TasksController extends $AsyncNotifier<void> {
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
