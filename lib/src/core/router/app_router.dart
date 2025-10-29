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
import 'package:liminetic/src/features/farm_os/financials/domain/financial_transaction_model.dart';
import 'package:liminetic/src/features/farm_os/financials/presentation/screens/add_transaction_screen.dart';
import 'package:liminetic/src/features/farm_os/financials/presentation/screens/financials_screen.dart';
import 'package:liminetic/src/features/farm_os/financials/presentation/screens/transaction_details_screen.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/screens/add_edit_inventory_item_screen.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/screens/inventory_item_details_screen.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/screens/edit_log_screen.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/screens/log_details_screen.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/screens/logs_screen.dart';
import 'package:liminetic/src/features/farm_os/logbook/presentation/screens/add_log_entry_screen.dart';
import 'package:liminetic/src/features/farm_os/settings/farm_management/presentation/screens/farm_details_screen.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/screens/add_location_screen.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/screens/location_details_screen.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/screens/locations_screen.dart';
import 'package:liminetic/src/features/farm_os/presentation/screens/add_farm_screen.dart'; // Import the new screen
import 'package:liminetic/src/features/farm_os/settings/appearance/presentation/screens/appearance_screen.dart';
import 'package:liminetic/src/features/farm_os/settings/farm_management/presentation/screens/farm_management_screen.dart';
import 'package:liminetic/src/features/farm_os/settings/modules/presentation/screens/modules_screen.dart';
import 'package:liminetic/src/features/farm_os/settings/notifications/presentation/screens/notifications_screen.dart';
import 'package:liminetic/src/features/farm_os/presentation/screens/home_screen.dart';
import 'package:liminetic/src/features/farm_os/settings/presentation/screens/settings_screen.dart';
import 'package:liminetic/src/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:liminetic/src/features/farm_os/settings/team/presentation/screens/my_team_screen.dart';
import 'package:liminetic/src/features/farm_os/tasks/domain/task_model.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/screens/create_task_screen.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/screens/edit_task_screen.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/screens/task_details_screen.dart';
import 'package:liminetic/src/features/farm_os/tasks/presentation/screens/tasks_screen.dart';

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
        path: '/locations',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LocationsScreen(),
        ),
        routes: [
          GoRoute(
            path: '/add-location',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const AddLocationScreen(),
            ),
          ),
          GoRoute(
            path: ':locationId', // e.g., /locations/xyz123
            pageBuilder: (context, state) {
              // Get the Location object passed during navigation
              final location = state.extra as Location;
              return buildPageWithFadeTransition(
                context: context,
                state: state,
                child: LocationDetailsScreen(location: location),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/tasks',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const TasksScreen(),
        ),
        routes: [
          // Add a new top-level route for creating tasks
          GoRoute(
            path: '/create-task',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const CreateTaskScreen(),
            ),
          ),
          GoRoute(
            path: ':taskId', // e.g., /tasks/xyz123
            pageBuilder: (context, state) {
              // Pass the whole Task object during navigation for efficiency
              final task = state.extra as Task;
              return buildPageWithFadeTransition(
                context: context,
                state: state,
                child: TaskDetailsScreen(task: task),
              );
            },
            routes: [
              GoRoute(
                path: 'edit', // e.g., /tasks/xyz123/edit
                pageBuilder: (context, state) {
                  final task = state.extra as Task;
                  return buildPageWithFadeTransition(
                    context: context,
                    state: state,
                    child: EditTaskScreen(task: task),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/logs',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LogsScreen(),
        ),
        routes: [
          GoRoute(
            path: '/add-log',
            pageBuilder: (context, state) {
              // Check if a pre-selected type was passed as an extra argument
              final preselectedType = state.extra as LogType?;
              return buildPageWithFadeTransition(
                context: context,
                state: state,
                child: AddLogEntryScreen(preselectedType: preselectedType),
              );
            },
          ),
          GoRoute(
            path: ':logId', // e.g., /logs/xyz123
            pageBuilder: (context, state) {
              final log = state.extra as LogEntry;
              return buildPageWithFadeTransition(
                context: context,
                state: state,
                child: LogDetailsScreen(log: log),
              );
            },
            routes: [
              GoRoute(
                path: 'edit', // e.g., /log/xyz123/edit
                pageBuilder: (context, state) {
                  final log = state.extra as LogEntry;
                  return buildPageWithFadeTransition(
                    context: context,
                    state: state,
                    child: EditLogScreen(log: log),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/inventory',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const InventoryListScreen(),
        ),
        routes: [
          GoRoute(
            path: '/add-inventory-item',
            pageBuilder: (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const AddEditInventoryItemScreen(),
            ),
          ),
          GoRoute(
            path: ':itemId', // e.g., /inventory/xyz123
            pageBuilder: (context, state) {
              final item = state.extra as InventoryItem;
              return buildPageWithFadeTransition(
                context: context,
                state: state,
                child: InventoryItemDetailsScreen(item: item),
              );
            },
            routes: [
              GoRoute(
                path: 'edit', // e.g., /inventory/xyz123/edit
                pageBuilder: (context, state) {
                  final item = state.extra as InventoryItem;
                  return buildPageWithFadeTransition(
                    context: context,
                    state: state,
                    child: AddEditInventoryItemScreen(item: item),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/financials',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const FinancialsScreen(),
        ),
        routes: [
          GoRoute(
            path: '/add-transaction',
            pageBuilder: (context, state) {
              // Extract the pre-selected type passed from the button press.
              // Default to 'expense' if nothing is passed.
              final initialType =
                  state.extra as TransactionType? ?? TransactionType.expense;
              return buildPageWithFadeTransition(
                context: context,
                state: state,
                child: AddTransactionScreen(initialType: initialType),
              );
            },
          ),
          GoRoute(
            path: ':transactionId', // e.g., /financials/xyz123
            pageBuilder: (context, state) {
              // Get the transaction object passed during navigation.
              final transaction = state.extra as FinancialTransaction;
              return buildPageWithFadeTransition(
                context: context,
                state: state,
                child: TransactionDetailsScreen(transaction: transaction),
              );
            },
          ),
        ],
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
