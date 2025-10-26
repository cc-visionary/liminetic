// lib/src/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import all necessary screens
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';
import 'package:liminetic/src/core/presentation/screens/splash_screen.dart';
import 'package:liminetic/src/features/auth/presentation/screens/login_screen.dart';
import 'package:liminetic/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:liminetic/src/features/farm_os/farm_management/presentation/screens/farm_details_screen.dart';
import 'package:liminetic/src/features/farm_os/presentation/screens/add_farm_screen.dart'; // Import the new screen
import 'package:liminetic/src/features/farm_os/appearance/presentation/screens/appearance_screen.dart';
import 'package:liminetic/src/features/farm_os/farm_management/presentation/screens/farm_management_screen.dart';
import 'package:liminetic/src/features/farm_os/modules/presentation/screens/modules_screen.dart';
import 'package:liminetic/src/features/farm_os/notifications/presentation/screens/notifications_screen.dart';
import 'package:liminetic/src/features/farm_os/presentation/screens/home_screen.dart';
import 'package:liminetic/src/features/farm_os/settings/presentation/screens/settings_screen.dart';
import 'package:liminetic/src/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:liminetic/src/features/farm_os/team/presentation/screens/my_team_screen.dart';

/// A reusable function to create a page with a custom fade transition.
/// This ensures all screen transitions in the app are smooth and consistent.
CustomTransitionPage<void> buildPageWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  );
}

// Placeholder Screens for drawer items
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const ResponsiveScaffold(
    title: 'Inventory',
    body: Center(child: Text('Inventory Screen')),
  );
}

class FinancialsScreen extends StatelessWidget {
  const FinancialsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const ResponsiveScaffold(
    title: 'Financials',
    body: Center(child: Text('Financials Screen')),
  );
}

/// The main router provider for the application.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch the session provider to react to login/logout state changes.
  final sessionState = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      // While the session is being determined, stay on the splash screen.
      if (sessionState.isLoading || sessionState.hasError) {
        return null;
      }

      final session = sessionState.value;
      final isLoggedIn = session?.isLoggedIn ?? false;
      final isAtAuthScreen =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isAtSplashScreen = state.matchedLocation == '/splash';

      // --- REDIRECT LOGIC ---

      // Case 1: User is NOT logged in.
      if (!isLoggedIn) {
        // If they are not already on an authentication screen, send them to login.
        return isAtAuthScreen ? null : '/login';
      }

      // Case 2: User IS logged in.
      if (isLoggedIn) {
        // If they are on the splash or an auth screen, they should be sent to the home screen.
        if (isAtSplashScreen || isAtAuthScreen) {
          return '/home';
        }
      }

      // In all other cases (e.g., a logged-in user navigating between app screens),
      // no redirect is needed.
      return null;
    },
    routes: [
      // --- AUTHENTICATION ROUTES ---
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SignUpScreen(),
        ),
      ),

      // --- MAIN APP ROUTES ---
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/inventory',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const InventoryScreen(),
        ),
      ),
      GoRoute(
        path: '/financials',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const FinancialsScreen(),
        ),
      ),
      // The route for creating an additional farm.
      GoRoute(
        path: '/add-farm',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const AddFarmScreen(),
        ),
      ),

      // --- SETTINGS ROUTES (with sub-routes) ---
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'profile',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const EditProfileScreen(),
            ),
          ),
          GoRoute(
            path: 'farm-management',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const FarmManagementScreen(), // The new list screen
            ),
            routes: [
              // **NEW**: Dynamic route for editing a specific farm
              GoRoute(
                path: ':farmId', // e.g., /settings/farm-management/xyz123
                pageBuilder: (context, state) {
                  final farmId = state.pathParameters['farmId']!;
                  return buildPageWithFadeTransition(
                    context: context,
                    state: state,
                    child: FarmDetailsScreen(farmId: farmId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'team',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const MyTeamScreen(),
            ),
          ),
          GoRoute(
            path: 'modules',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const ModulesScreen(),
            ),
          ),
          GoRoute(
            path: 'notifications',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: 'appearance',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const AppearanceScreen(),
            ),
          ),
          GoRoute(
            path: '/add-farm',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const AddFarmScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
