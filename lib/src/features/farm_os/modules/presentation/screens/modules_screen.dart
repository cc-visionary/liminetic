// lib/src/features/farm_os/modules/presentation/screens/modules_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/features/farm_os/modules/presentation/controllers/modules_controller.dart';

/// A data class to represent a single module option in the UI.
class ModuleOption {
  final String name;
  final String description;
  final IconData icon;
  final bool isAvailable;
  bool isActive;

  ModuleOption({
    required this.name,
    required this.description,
    required this.icon,
    required this.isAvailable,
    required this.isActive,
  });
}

/// A screen for managing the farm's active and upcoming modules.
class ModulesScreen extends ConsumerStatefulWidget {
  const ModulesScreen({super.key});

  @override
  ConsumerState<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends ConsumerState<ModulesScreen> {
  // Local state to manage the UI before saving.
  late List<ModuleOption> _moduleOptions;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Get the currently active modules from the session.
      final activeModules =
          ref.watch(sessionProvider).value?.activeFarm?.activeModules ?? [];
      _initializeOptions(activeModules);
      _isInitialized = true;
    }
  }

  /// Initializes the local list of module options based on the farm's data.
  void _initializeOptions(List<String> activeModules) {
    _moduleOptions = [
      // --- Available Modules ---
      ModuleOption(
        name: 'Swine Management',
        description: 'Active',
        icon: Icons.pest_control_rodent_outlined,
        isAvailable: true,
        isActive: activeModules.contains('Swine Management'),
      ),
      // --- Coming Soon Modules ---
      ModuleOption(
        name: 'Poultry Management',
        description: 'Coming Soon',
        icon: Icons.egg_outlined,
        isAvailable: false,
        isActive: activeModules.contains('Poultry Management'),
      ),
      ModuleOption(
        name: 'Crop Management',
        description: 'Coming Soon',
        icon: Icons.grass_outlined,
        isAvailable: false,
        isActive: activeModules.contains('Crop Management'),
      ),
      ModuleOption(
        name: 'Cattle Management',
        description: 'Coming Soon',
        icon: Icons.agriculture_outlined, // Example icon
        isAvailable: false,
        isActive: activeModules.contains('Cattle Management'),
      ),
    ];
  }

  /// Converts the local UI state back into a list of strings and saves it.
  void _saveChanges() {
    final newActiveModules = _moduleOptions
        .where((option) => option.isActive)
        .map((option) => option.name)
        .toList();

    ref
        .read(modulesControllerProvider.notifier)
        .updateModules(newActiveModules);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the controller's state for success/error feedback.
    ref.listen<AsyncValue<void>>(modulesControllerProvider, (previous, next) {
      if ((previous?.isLoading ?? false) && !next.isLoading && !next.hasError) {
        // On success, invalidate the session to refetch the new farm data
        // and pop the screen.
        ref.invalidate(sessionProvider);
        context.pop();
      }
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    final controllerState = ref.watch(modulesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Modules'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: controllerState.isLoading ? null : _saveChanges,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _SectionTitle(title: 'AVAILABLE'),
          ..._moduleOptions
              .where((m) => m.isAvailable)
              .map(
                (option) => _ModuleTile(
                  option: option,
                  onChanged: (newValue) =>
                      setState(() => option.isActive = newValue),
                ),
              ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'COMING SOON'),
          ..._moduleOptions
              .where((m) => !m.isAvailable)
              .map(
                (option) => _ModuleTile(
                  option: option,
                  onChanged: null, // Disabled
                ),
              ),
        ],
      ),
    );
  }
}

/// A custom widget for the section titles.
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
  const _ModuleTile({required this.option, required this.onChanged});

  final ModuleOption option;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: SwitchListTile(
          value: option.isActive,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
          secondary: CircleAvatar(
            backgroundColor: option.isAvailable
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            child: Icon(
              option.icon,
              color: option.isAvailable
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
          title: Text(
            option.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(option.description),
        ),
      ),
    );
  }
}
