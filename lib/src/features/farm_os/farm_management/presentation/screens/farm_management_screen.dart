// lib/src/features/farm_os/farm_details/presentation/screens/farm_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';

/// A screen that lists all farms associated with the current user, allowing
/// them to select one to view or edit its details.
class FarmManagementScreen extends ConsumerWidget {
  const FarmManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the list of all farms from the user's session.
    final allFarms = ref.watch(sessionProvider).value?.allFarms ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Farm Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: allFarms.length,
        itemBuilder: (context, index) {
          final farm = allFarms[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: Text(
                farm.farmName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to the detail screen, passing the specific farm's ID.
                context.go('/settings/farm-management/${farm.id}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-farm'),
        child: const Icon(Icons.add),
        tooltip: 'Add New Farm',
      ),
    );
  }
}
