// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/core/router/app_router.dart';
import 'package:liminetic/src/core/theme/app_theme.dart';
import 'package:liminetic/src/core/theme/appearance_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(appearanceProvider);

    return MaterialApp.router(
      title: 'Liminetic',

      // 1. Set the light theme
      theme: AppTheme.lightTheme,

      // 2. Set the dark theme
      darkTheme: AppTheme.darkTheme,

      // 3. Tell Flutter to automatically switch based on the device setting
      themeMode: themeMode,

      routerConfig: goRouter,
    );
  }
}
