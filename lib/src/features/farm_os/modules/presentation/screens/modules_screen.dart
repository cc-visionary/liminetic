// lib/src/features/farm_os/modules/presentation/screens/modules_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A screen for managing the farm's active and upcoming modules.
class ModulesScreen extends ConsumerStatefulWidget {
  const ModulesScreen({super.key});

  @override
  ConsumerState<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends ConsumerState<ModulesScreen> {
  // Local state for the toggle. This would eventually be driven by a provider
  // that reads/writes from the farm's document in Firestore.
  bool _isSwineActive = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Modules')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _SectionTitle(title: 'AVAILABLE'),
          _ModuleTile(
            icon: Icons.pest_control_rodent_outlined,
            title: 'Swine Management',
            subtitle: _isSwineActive ? 'Active' : 'Inactive',
            value: _isSwineActive,
            onChanged: (newValue) {
              setState(() {
                _isSwineActive = newValue;
                // TODO: Add call to a controller to update this in Firestore.
              });
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'COMING SOON'),
          _ModuleTile(
            icon: Icons.egg_outlined,
            title: 'Poultry Management',
            value: false,
            onChanged: null, // Disabled
          ),
          _ModuleTile(
            icon: Icons.grass_outlined,
            title: 'Crop Management',
            value: false,
            onChanged: null, // Disabled
          ),
          _ModuleTile(
            icon: Icons.agriculture_outlined,
            title: 'Cattle Management',
            value: false,
            onChanged: null, // Disabled
          ),
        ],
      ),
    );
  }
}

/// A custom widget for the section titles (e.g., "AVAILABLE").
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

/// A custom, styled tile for a single module.
class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onChanged != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
          secondary: CircleAvatar(
            backgroundColor: isEnabled
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            child: Icon(
              icon,
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: subtitle != null ? Text(subtitle!) : null,
        ),
      ),
    );
  }
}