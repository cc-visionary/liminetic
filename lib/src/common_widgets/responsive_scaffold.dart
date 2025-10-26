// lib/src/common_widgets/responsive_scaffold.dart

import 'package:flutter/material.dart';
import 'package:liminetic/src/common_widgets/app_drawer.dart';

/// A responsive scaffold that adapts its layout based on screen width.
///
/// On mobile, it shows a standard AppBar with a hidden drawer. On desktop,
/// it shows a permanent side navigation rail. It now also supports a
/// `FloatingActionButton`.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.floatingActionButton, // NEW: Add optional FAB parameter
  });

  /// The main content of the screen.
  final Widget body;

  /// The title displayed in the AppBar.
  final String title;

  /// An optional floating action button to display.
  final Widget? floatingActionButton;

  /// The screen width breakpoint for switching between layouts.
  static const double desktopBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // --- DESKTOP / WIDE SCREEN LAYOUT ---
        if (constraints.maxWidth >= desktopBreakpoint) {
          return Row(
            children: [
              // The permanent navigation drawer.
              const AppDrawer(),
              const VerticalDivider(width: 1, thickness: 1),
              // The main screen content area.
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(title),
                    // In desktop, the menu button is not needed.
                    automaticallyImplyLeading: false,
                  ),
                  body: body,
                  // The FAB is placed within the main content area's scaffold.
                  floatingActionButton: floatingActionButton,
                ),
              ),
            ],
          );
        }
        // --- MOBILE / NARROW SCREEN LAYOUT ---
        else {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            // The standard hidden drawer for mobile.
            drawer: const AppDrawer(),
            body: body,
            // The FAB is placed on the main mobile scaffold.
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }
}
