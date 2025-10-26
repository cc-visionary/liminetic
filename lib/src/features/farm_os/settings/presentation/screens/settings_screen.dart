// lib/src/features/farm_os/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _SettingsItem(
            icon: Icons.person_outline,
            title: 'Profile Information',
            onTap: () => context.go('/settings/profile'),
          ),
          _SettingsItem(
            icon: Icons.home_work_outlined,
            title: 'Farm Management', // Changed from "Farm Details"
            onTap: () => context.go('/settings/farm-management'), // New path
          ),
          _SettingsItem(
            icon: Icons.people_outline,
            title: 'Manage Team',
            onTap: () => context.go('/settings/team'),
          ),
          _SettingsItem(
            icon: Icons.extension_outlined,
            title: 'Manage Modules',
            onTap: () => context.go('/settings/modules'),
          ),
          _SettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => context.go('/settings/notifications'),
          ),
          _SettingsItem(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            onTap: () => context.go('/settings/appearance'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
