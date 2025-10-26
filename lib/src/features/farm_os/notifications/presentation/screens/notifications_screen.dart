// lib/src/features/farm_os/notifications/presentation/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A screen for managing notification preferences.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Local state for now. In a real app, this would be read from and saved to
  // the user's profile in Firestore.
  bool _enableNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive alerts for important farm events.'),
              value: _enableNotifications,
              onChanged: (bool value) {
                setState(() {
                  _enableNotifications = value;
                  // TODO: Add a controller call to save this preference.
                });
              },
            ),
          ),
          // Add more granular notification toggles here later
        ],
      ),
    );
  }
}