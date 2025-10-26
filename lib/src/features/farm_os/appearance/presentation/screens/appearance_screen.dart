// lib/src/features/farm_os/appearance/presentation/screens/appearance_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/core/theme/appearance_provider.dart';

/// A screen where the user can change the application's theme.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme mode from the provider.
    final currentTheme = ref.watch(appearanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _AppearanceTile(
            title: 'System Default',
            subtitle: 'Follow the device\'s theme setting.',
            value: ThemeMode.system,
            groupValue: currentTheme,
            onChanged: (theme) =>
                ref.read(appearanceProvider.notifier).changeTheme(theme!),
          ),
          _AppearanceTile(
            title: 'Light',
            subtitle: 'Use the light theme.',
            value: ThemeMode.light,
            groupValue: currentTheme,
            onChanged: (theme) =>
                ref.read(appearanceProvider.notifier).changeTheme(theme!),
          ),
          _AppearanceTile(
            title: 'Dark',
            subtitle: 'Use the dark theme.',
            value: ThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (theme) =>
                ref.read(appearanceProvider.notifier).changeTheme(theme!),
          ),
        ],
      ),
    );
  }
}

/// A custom widget for a single theme selection option.
class _AppearanceTile extends StatelessWidget {
  const _AppearanceTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: RadioListTile<ThemeMode>(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
