// lib/src/features/farm_os/logbook/presentation/controllers/logbook_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/logbook/data/logbook_repository.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';

part 'logbook_controller.g.dart';

/// A data class to hold the current filter state for the logbook.
class LogbookFilter {
  final LogType? type; // The selected log type, or null for "All"
  final String query; // The search query

  LogbookFilter({this.type, this.query = ''});
}

/// Provider to hold the current filter and search query state.
@riverpod
class LogbookFilterNotifier extends _$LogbookFilterNotifier {
  @override
  LogbookFilter build() => LogbookFilter();

  void setFilterType(LogType? type) {
    state = LogbookFilter(type: type, query: state.query);
  }

  void setSearchQuery(String query) {
    state = LogbookFilter(type: state.type, query: query.toLowerCase());
  }
}

/// A base provider that fetches the raw, unfiltered stream of all logs.
@riverpod
Stream<List<LogEntry>> rawLogbookStream(Ref ref) {
  final logRepo = ref.watch(logbookRepositoryProvider);
  final farmId = ref.watch(sessionProvider).value?.activeFarm?.id;
  if (farmId == null) return Stream.value([]);
  return logRepo.getLogsStream(farmId);
}

/// A derived provider that filters and searches the raw list of logs.
/// The UI will watch this provider to display the final, visible list.
@riverpod
List<LogEntry> filteredLogbook(Ref ref) {
  final logsAsyncValue = ref.watch(rawLogbookStreamProvider);
  final filter = ref.watch(logbookFilterProvider);

  return logsAsyncValue.maybeWhen(
    data: (logs) {
      // Apply type filter
      var filteredLogs = filter.type == null
          ? logs
          : logs.where((log) => log.type == filter.type).toList();

      // Apply search query
      if (filter.query.isNotEmpty) {
        filteredLogs = filteredLogs.where((log) {
          // Search in title and actor name
          return log.title.toLowerCase().contains(filter.query) ||
              log.actorName.toLowerCase().contains(filter.query);
        }).toList();
      }
      return filteredLogs;
    },
    orElse: () => [],
  );
}

/// Controller for handling actions related to the logbook.
@riverpod
class LogbookController extends _$LogbookController {
  @override
  FutureOr<void> build() {}

  /// **UPDATED**: Adds a new log entry of any type to the database.
  /// This single method replaces all previous type-specific methods.
  Future<void> addLogEntry({
    required LogType type,
    required Map<String, dynamic> payload,
  }) async {
    final logRepo = ref.read(logbookRepositoryProvider);
    final session = ref.read(sessionProvider).value;
    final farmId = session?.activeFarm?.id;
    final currentUser = session?.appUser;

    if (farmId == null || currentUser == null) {
      throw Exception('Cannot add log: No active session found.');
    }

    final newLog = LogEntry(
      id: '', // Firestore generates this
      type: type,
      timestamp:
          Timestamp.now(), // Always use the current time for the log itself
      actorId: currentUser.uid,
      actorName: currentUser.username,
      payload: payload,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => logRepo.addLogEntry(farmId, newLog));
  }

  Future<void> editLogEntry(String logId, Map<String, dynamic> payload) async {
    final logRepo = ref.read(logbookRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm.');
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => logRepo.updateLogEntry(farmId, logId, {'payload': payload}),
    );
  }

  /// Deletes a log entry.
  Future<void> deleteLogEntry(String logId) async {
    final logRepo = ref.read(logbookRepositoryProvider);
    final farmId = ref.read(sessionProvider).value?.activeFarm?.id;
    if (farmId == null) throw Exception('No active farm.');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => logRepo.deleteLogEntry(farmId, logId));
  }
}
