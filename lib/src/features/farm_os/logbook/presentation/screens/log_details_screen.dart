// lib/src/features/farm_os/logbook/presentation/screens/log_details_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liminetic/src/common_widgets/detail_row.dart';
import 'package:liminetic/src/core/utils/string_extensions.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/controllers/logbook_controller.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/controllers/log_details_controller.dart';

/// A screen that shows the details of a single log entry.
class LogDetailsScreen extends ConsumerWidget {
  final LogEntry log;
  const LogDetailsScreen({super.key, required this.log});

  /// Shows a confirmation dialog before deleting the log.
  Future<void> _deleteLog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log?'),
        content: const Text(
          'Are you sure you want to delete this log entry permanently?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(logbookControllerProvider.notifier)
            .deleteLogEntry(log.id);
        if (context.mounted) context.pop();
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final assigneeNameAsync = ref.watch(assigneeNameProvider(log.actorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/logs/${log.id}/edit', extra: log),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteLog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(_getLogTypeDisplayName(log.type))),
            const SizedBox(height: 24),
            DetailRow(
              icon: Icons.person_outline,
              title: 'Logged By',
              content: assigneeNameAsync.when(
                data: (name) => name,
                loading: () => 'Loading...',
                error: (_, __) => 'Error',
              ),
            ),
            DetailRow(
              icon: Icons.calendar_today_outlined,
              title: 'Date',
              content: DateFormat.yMMMd().format(log.timestamp.toDate()),
            ),
            const Divider(height: 32),
            ..._buildPayloadDetails(
              ref,
            ), // Dynamically build details from the payload
          ],
        ),
      ),
    );
  }

  /// Builds a list of widgets to display the payload data based on log type.
  List<Widget> _buildPayloadDetails(WidgetRef ref) {
    switch (log.type) {
      case LogType.visitorEntry:
        final locationIds = List<String>.from(
          log.payload['locationsVisited'] ?? [],
        );
        final locationsAsync = ref.watch(locationNamesProvider(locationIds));

        final timeInValue = log.payload['timeIn'] as Timestamp?;
        final timeOutValue = log.payload['timeOut'] as Timestamp?;

        return [
          DetailRow(
            icon: Icons.info_outline,
            title: 'Purpose of Visit',
            content: log.payload['purposeOfVisit'] ?? 'N/A',
          ),
          DetailRow(
            icon: Icons.login,
            title: 'Time In',
            content: timeInValue != null
                ? DateFormat.jm().format(timeInValue.toDate())
                : 'Not recorded',
          ),
          DetailRow(
            icon: Icons.logout,
            title: 'Time Out',
            content: timeOutValue != null
                ? DateFormat.jm().format(timeOutValue.toDate())
                : 'Not logged out',
          ),
          locationsAsync.when(
            data: (names) => DetailRow(
              icon: Icons.location_on_outlined,
              title: 'Locations Visited',
              content: names,
            ),
            loading: () => const DetailRow(
              icon: Icons.location_on_outlined,
              title: 'Locations Visited',
              content: 'Loading...',
            ),
            error: (_, __) => const DetailRow(
              icon: Icons.location_on_outlined,
              title: 'Locations Visited',
              content: 'Error',
            ),
          ),
        ];
      case LogType.deliveryReceived:
        return [
          DetailRow(
            icon: Icons.business_outlined,
            title: 'Supplier Name',
            content: log.payload['supplierName'] ?? 'N/A',
          ),
          DetailRow(
            icon: Icons.inventory_2_outlined,
            title: 'Items Received',
            content: log.payload['itemsReceived'] ?? 'N/A',
          ),
        ];
      case LogType.generalObservation:
        return [
          DetailRow(
            icon: Icons.notes_outlined,
            title: 'Note',
            content: log.payload['notes'] ?? 'N/A',
          ),
        ];
      // Add more cases for other log types here
      default:
        return [const Text('No specific details for this log type.')];
    }
  }

  /// Helper to get a user-friendly name for each enum value.
  String _getLogTypeDisplayName(LogType type) {
    // Example: "visitorEntry" becomes "Visitor Entry"
    return type.name
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])[A-Z]'),
          (match) => ' ${match.group(0)}',
        )
        .capitalize(); // This now uses the imported extension.
  }
}
