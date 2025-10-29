// lib/src/features/farm_os/logbook/presentation/screens/logs_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/common_widgets/filter_chip_row.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/controllers/logbook_controller.dart';

// Mapping for Logs
const Map<LogType?, String> logFilterMap = {
  null: 'All', // null means no filter
  LogType.visitorEntry: 'Visitors',
  LogType.event: 'Events',
  LogType.deliveryReceived: 'Deliveries',
};

/// The main screen for viewing the farm's logbook with search and filtering.
class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref
            .read(logbookFilterProvider.notifier)
            .setSearchQuery(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Triggers the search by updating the filter provider with the current text.
  void _performSearch() {
    // Cancel any pending debounce timer to search immediately.
    _debounce?.cancel();
    ref
        .read(logbookFilterProvider.notifier)
        .setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final logsAsyncValue = ref.watch(rawLogbookStreamProvider);
    final filteredLogs = ref.watch(filteredLogbookProvider);
    final currentFilterType = ref.watch(logbookFilterProvider).type;
    final currentFilterLabel = logFilterMap[currentFilterType] ?? 'All';

    return ResponsiveScaffold(
      title: 'Logs',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/logs/add-log'),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        // Wrap the body content in a Stack.
        children: [
          // This Column holds your main UI (search, filters, list).
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                  ),
                  onFieldSubmitted: (_) => _performSearch(),
                ),
              ),
              FilterChipRow(
                options: logFilterMap.values.toList(),
                selectedValue: currentFilterLabel,
                onSelected: (label) {
                  final newFilterType = logFilterMap.entries
                      .firstWhere((e) => e.value == label)
                      .key;
                  ref
                      .read(logbookFilterProvider.notifier)
                      .setFilterType(newFilterType);
                },
              ),
              Expanded(
                child: logsAsyncValue.when(
                  data: (_) {
                    if (filteredLogs.isEmpty &&
                        _searchController.text.isEmpty) {
                      return const Center(child: Text('No log entries found.'));
                    }
                    if (filteredLogs.isEmpty &&
                        _searchController.text.isNotEmpty) {
                      return const Center(
                        child: Text('No results for your search.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) =>
                          _LogCard(log: filteredLogs[index]),
                    );
                  },
                  // The loading case inside .when now returns an empty widget.
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),

          // This is the loading overlay.
          // It's only visible during the initial load when there's no data yet.
          if (logsAsyncValue.isLoading && !logsAsyncValue.hasValue)
            Positioned.fill(
              child: Container(
                // Semi-transparent background to dim the content underneath.
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final LogEntry log;
  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Icon(log.icon)),
        title: Text(
          log.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(log.subtitle),
        onTap: () => context.push('/logs/${log.id}', extra: log),
      ),
    );
  }
}
