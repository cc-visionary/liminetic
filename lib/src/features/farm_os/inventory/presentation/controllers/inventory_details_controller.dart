// lib/src/features/farm_os/inventory/presentation/controllers/inventory_details_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/controllers/logbook_controller.dart';

part 'inventory_details_controller.g.dart';

/// A provider that fetches and filters the logbook to find all usage history
/// for a specific inventory item.
///
/// This is now a synchronous provider. It watches the raw stream's
/// state and returns a filtered list of logs only when the data is available.
@riverpod
List<LogEntry> itemUsageHistory(Ref ref, String itemId) {
  // Watch the AsyncValue state of the raw logbook stream.
  final allLogsAsync = ref.watch(rawLogbookStreamProvider);

  // Use .maybeWhen to safely handle the data. This returns the filtered list
  // on success, or an empty list during loading or error states.
  return allLogsAsync.maybeWhen(
    data: (logs) {
      // Filter the list to find only 'inventoryUsage' logs that match the given itemId.
      return logs.where((log) {
        return log.type == LogType.inventoryUsage &&
            log.payload['itemId'] == itemId;
      }).toList();
    },
    orElse: () => [], // Return an empty list if there's no data yet.
  );
}
