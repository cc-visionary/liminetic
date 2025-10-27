// lib/src/features/farm_os/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    final farmName = session?.activeFarm?.farmName ?? 'Liminetic Farms';

    // Get the active modules from the current farm session.
    final activeModules =
        ref.watch(sessionProvider).value?.activeFarm?.activeModules ?? [];

    return ResponsiveScaffold(
      title: farmName,
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          const _FarmOverviewCard(),
          _ModuleCard(
            title: 'Farm OS',
            actions: [
              _ModuleAction(
                icon: Icons.check_circle_outline,
                label: 'Tasks',
                onTap: () => context.go('/tasks'),
              ),
              _ModuleAction(
                icon: Icons.inventory_2_outlined,
                label: 'Inventory',
                onTap: () => context.go('/inventory'),
              ),
              _ModuleAction(
                icon: Icons.attach_money,
                label: 'Financials',
                onTap: () => context.go('/financials'),
              ),
              _ModuleAction(
                icon: Icons.book_outlined,
                label: 'Logbook',
                onTap: () => context.go('/logs'),
              ),
            ],
          ),
          // Conditionally render the Swine Module card.
          // This `if` statement is clean, readable, and directly tied to our single source of truth.
          if (activeModules.contains('Swine Management'))
            _ModuleCard(
              title: 'Swine Module',
              actions: [
                _ModuleAction(
                  icon: Icons.add_circle_outline,
                  label: 'Add Pig',
                  onTap: () {},
                ),
                _ModuleAction(
                  icon: Icons.child_friendly_outlined,
                  label: 'Log Farrowing',
                  onTap: () {},
                ),
                _ModuleAction(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Health Log',
                  onTap: () {},
                ),
                _ModuleAction(
                  icon: Icons.visibility_outlined,
                  label: 'View Sows',
                  onTap: () {},
                ),
                _ModuleAction(
                  icon: Icons.sync_outlined,
                  label: 'Breeding Cycles',
                  onTap: () {},
                ),
                _ModuleAction(
                  icon: Icons.move_up_outlined,
                  label: 'Move Pigs',
                  onTap: () {},
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// --- Reusable Widgets for HomeScreen ---

class _FarmOverviewCard extends StatelessWidget {
  const _FarmOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _OverviewItem(count: '12', label: 'Tasks Today'),
                _OverviewItem(count: '3', label: 'Animals Requiring Attention'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({required this.count, required this.label});
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.title, required this.actions});
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleAction extends StatelessWidget {
  const _ModuleAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap; // Added onTap callback

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Wrapped with InkWell for ripple effect and interactivity
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.background,
            child: Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
