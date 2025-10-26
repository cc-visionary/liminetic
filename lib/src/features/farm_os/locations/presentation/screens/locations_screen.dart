// lib/src/features/farm_os/locations/presentation/screens/locations_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';

/// The main screen for viewing and managing farm locations.
class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the RAW stream provider to handle the loading and error states.
    final locationsAsyncValue = ref.watch(rawLocationsStreamProvider);
    // 2. Watch the DERIVED provider to get the processed, hierarchical data.
    final locationNodes = ref.watch(locationsProvider);

    return ResponsiveScaffold(
      title: 'Locations',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/locations/add-location'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Header section with the "View on Map" button.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    /* TODO: Navigate to Farm Map Screen */
                  },
                  icon: const Icon(Icons.map_outlined, size: 20),
                  label: const Text('View on Map'),
                  style: ElevatedButton.styleFrom(
                    // Using accent color for secondary actions
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          // The main list of locations.
          Expanded(
            child: locationsAsyncValue.when(
              data: (_) {
                if (locationNodes.isEmpty) {
                  return const Center(child: Text('No locations created yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: locationNodes.length,
                  itemBuilder: (context, index) {
                    final node = locationNodes[index];
                    // Use an ExpansionTile for top-level locations to make them expandable.
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          child: Icon(
                            _getIconForLocationType(node.parent.type),
                          ),
                        ),
                        title: Text(
                          node.parent.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text('${node.children.length} Pens'),
                            ), // Dynamic label
                            const Icon(Icons.expand_more),
                          ],
                        ),
                        children: node.children.map((child) {
                          // Display child locations as simple, indented ListTiles.
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                _getIconForLocationType(child.type),
                                color: Colors.grey[600],
                              ),
                            ),
                            title: Text(child.name),
                            onTap: () => context.push(
                              '/locations/${child.id}',
                              extra: child,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  /// A helper function to return an appropriate icon based on the location type.
  IconData _getIconForLocationType(String type) {
    switch (type.toLowerCase()) {
      case 'building':
        return Icons.home_work_outlined;
      case 'pasture':
      case 'paddock':
        return Icons.grid_on;
      case 'orchard':
        return Icons.notifications_active_outlined;
      case 'pen':
        return Icons.tag;
      default:
        return Icons.location_pin;
    }
  }
}
