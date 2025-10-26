// lib/src/common_widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:liminetic/src/features/auth/presentation/controllers/session_controller.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';

/// A responsive navigation drawer for the application.
///
/// This widget adapts its appearance based on the screen width. On wider screens
/// (desktop), it can be expanded or collapsed. On smaller screens (mobile), it
/// functions as a standard hidden drawer.
class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  /// A state variable to control the expanded or collapsed view of the drawer
  /// in desktop mode. Defaults to `false` (expanded).
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    // Watch the user's session state to get user details.
    final session = ref.watch(sessionProvider).value;
    final user = session?.appUser;
    final theme = Theme.of(context);

    // Get the current route to highlight the active navigation item.
    final currentRoute = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.fullPath;

    // Check if the layout is wide enough to be considered a desktop view.
    final isDesktop =
        MediaQuery.of(context).size.width >=
        ResponsiveScaffold.desktopBreakpoint;

    // AnimatedContainer provides a smooth transition when the drawer's width changes.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isExpanded
          ? 280
          : 80, // Animate between expanded and collapsed widths.
      child: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerHeader(
                    username: user?.username ?? 'Guest User',
                    email: user?.email ?? '',
                    isExpanded: _isExpanded,
                  ),
                  const Divider(height: 1),
                  _FarmSwitcher(isExpanded: _isExpanded),
                  _DrawerSectionTitle(
                    title: 'FARM OS',
                    isExpanded: _isExpanded,
                  ),
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isExpanded: _isExpanded,
                    isSelected: currentRoute == '/home',
                    onTap: () => context.go('/home'),
                  ),
                  _DrawerItem(
                    icon: Icons.location_pin,
                    title: 'Locations',
                    isExpanded: _isExpanded,
                    isSelected: currentRoute.startsWith(
                      '/locations',
                    ), // Selects for parent and child routes
                    onTap: () => context.go('/locations'),
                  ),
                  _DrawerItem(
                    icon: Icons.check_circle_outline,
                    title: 'Tasks',
                    isExpanded: _isExpanded,
                    isSelected: currentRoute.startsWith('/tasks'),
                    onTap: () => context.go('/tasks'),
                  ),
                  _DrawerItem(
                    icon: Icons.book_outlined,
                    title: 'Logbook',
                    isExpanded: _isExpanded,
                    isSelected: currentRoute.startsWith('/logs'),
                    onTap: () => context.go('/logs'),
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventory',
                    isExpanded: _isExpanded,
                    isSelected: currentRoute.startsWith('/inventory'),
                    onTap: () => context.go('/inventory'),
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Financials',
                    isExpanded: _isExpanded,
                    isSelected: currentRoute == '/financials',
                    onTap: () => context.go('/financials'),
                  ),
                  // ... Add other drawer items for FARM OS here ...
                  _DrawerSectionTitle(
                    title: 'MY MODULES',
                    isExpanded: _isExpanded,
                  ),
                  _DrawerItem(
                    icon: Icons.pest_control_rodent_outlined,
                    title: 'Swine Dashboard',
                    isExpanded: _isExpanded,
                    isSelected: false, // Update with correct route later
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // --- Bottom-aligned action items ---
            const Divider(height: 1),

            // Only show the collapse/expand button in desktop view.
            if (isDesktop)
              _DrawerItem(
                icon: _isExpanded
                    ? Icons.arrow_back_ios_new
                    : Icons.arrow_forward_ios,
                title: _isExpanded ? 'Collapse' : 'Expand',
                isExpanded: _isExpanded,
                onTap: () => setState(() => _isExpanded = !_isExpanded),
              ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              isExpanded: _isExpanded,
              isSelected: currentRoute.startsWith('/settings'),
              onTap: () => context.go('/settings'),
            ),
            _DrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              isExpanded: _isExpanded,
              onTap: () => ref.read(authControllerProvider.notifier).signOut(),
            ),

            // Only show the version number when the drawer is expanded.
            if (_isExpanded)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('v1.0.0', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays the current farm and allows switching between farms.
class _FarmSwitcher extends ConsumerWidget {
  final bool isExpanded;
  const _FarmSwitcher({required this.isExpanded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    final currentFarm = session?.activeFarm;
    final allFarms = session?.allFarms ?? [];
    final theme = Theme.of(context);

    // Listen to the controller to invalidate the session provider on success,
    // ensuring the UI rebuilds with the new active farm.
    ref.listen<AsyncValue<void>>(sessionControllerProvider, (prev, next) {
      if (!next.isLoading && !next.hasError) {
        ref.invalidate(sessionProvider);
      }
    });

    // If not expanded in desktop view, show nothing.
    if (!isExpanded) {
      return const SizedBox.shrink();
    }

    // If the user has only one farm (or none), just display the name statically.
    if (allFarms.length <= 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentFarm?.farmName ?? 'No Farm',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If the user has multiple farms, show the dropdown switcher.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.dividerColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentFarm?.id,
            isExpanded: true,
            icon: const Icon(Icons.unfold_more),
            onChanged: (String? newFarmId) {
              if (newFarmId != null && newFarmId != currentFarm?.id) {
                ref
                    .read(sessionControllerProvider.notifier)
                    .switchActiveFarm(newFarmId);
              }
            },
            items: allFarms.map((farm) {
              return DropdownMenuItem<String>(
                value: farm.id,
                child: Text(
                  farm.farmName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// A custom widget for the header section of the drawer.
///
/// Displays the user's avatar, username, and email. Adapts its layout
/// based on the `isExpanded` state.
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.username,
    required this.email,
    required this.isExpanded,
  });

  final String username;
  final String email;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isExpanded ? 20 : 16,
        60,
        isExpanded ? 20 : 16,
        20,
      ),
      child: isExpanded
          ? Row(
              // Expanded view shows avatar and text side-by-side.
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'G',
                    style: TextStyle(
                      fontSize: 24,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : CircleAvatar(
              // Collapsed view only shows the avatar.
              radius: 24,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'G',
                style: TextStyle(
                  fontSize: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
    );
  }
}

/// A custom widget for the section titles (e.g., "FARM OS").
///
/// Only displays the text when the drawer is expanded.
class _DrawerSectionTitle extends StatelessWidget {
  const _DrawerSectionTitle({required this.title, required this.isExpanded});
  final String title;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return isExpanded
        ? Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: 1.2,
              ),
            ),
          )
        : const SizedBox(height: 24); // Renders as empty space when collapsed.
  }
}

/// A custom widget for a single, stylable, and interactive drawer item.
///
/// Adapts its layout for expanded and collapsed states and changes style
/// when it is the currently selected route.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isExpanded,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isExpanded;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dynamically set colors based on selection status and theme mode for a perfect match.
    final Color? backgroundColor = isSelected
        ? (colorScheme.brightness == Brightness.light
              ? const Color(0xFFE6F5EC)
              : colorScheme.primary.withOpacity(0.2))
        : Colors.transparent;
    final Color contentColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(icon, color: contentColor),
                // Only show the title and SizedBox if the drawer is expanded.
                if (isExpanded) const SizedBox(width: 16),
                if (isExpanded)
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: contentColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
