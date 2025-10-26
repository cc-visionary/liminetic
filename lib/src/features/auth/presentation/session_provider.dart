// lib/src/features/auth/presentation/session_provider.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/features/auth/data/auth_repository.dart';
import 'package:liminetic/src/features/auth/domain/user_model.dart';
import 'package:liminetic/src/features/farm_os/data/farm_repository.dart';
import 'package:liminetic/src/features/farm_os/domain/farm_model.dart';

/// A model class holding the complete session state of the user.
/// It now includes a list of all farms the user is a member of.
class SessionState {
  final User? firebaseUser;
  final AppUser? appUser;
  final Farm? activeFarm;
  final List<Farm> allFarms; // NEW: Holds all farms for the user

  const SessionState({
    this.firebaseUser,
    this.appUser,
    this.activeFarm,
    this.allFarms = const [], // Default to an empty list
  });

  bool get isLoggedIn => firebaseUser != null;
}

/// The single source of truth for the user's session.
///
/// This StreamProvider reacts to Firebase auth state changes in real-time.
/// When a user signs up, logs in, or logs out, this provider automatically
/// rebuilds and fetches all necessary data (user profile, all their farms,
/// and the currently active farm) to provide a complete SessionState to the app.
final sessionProvider = StreamProvider<SessionState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final farmRepo = ref.watch(farmRepositoryProvider);

  // Listen to the auth state stream continuously.
  return authRepo.authStateChanges.asyncMap((firebaseUser) async {
    // When the stream emits `null`, the user is logged out.
    if (firebaseUser == null) {
      return const SessionState();
    }

    // When the stream emits a `User`, the user is logged in.
    // Fetch their custom user profile from Firestore.
    final appUser = await authRepo.getUserData(firebaseUser.uid);
    if (appUser == null) {
      // Failsafe: If user exists in Auth but not Firestore, something is wrong.
      // Log them out to prevent a broken state.
      await authRepo.signOut();
      return const SessionState();
    }

    // NEW: Fetch all farms the user belongs to using their `farmIds` list.
    // This requires a `getFarmsByIds` method in your FarmRepository.
    final allFarms = await farmRepo.getFarmsByIds(appUser.farmIds);

    // Determine the active farm from the list of all farms.
    Farm? activeFarm;
    if (appUser.activeFarmId != null && allFarms.isNotEmpty) {
      // Find the farm in the list that matches the activeFarmId.
      activeFarm = allFarms.firstWhere(
        (farm) => farm.id == appUser.activeFarmId,
        orElse: () => allFarms.first, // Fallback to the first farm if not found
      );
    } else if (allFarms.isNotEmpty) {
      // If no active farm is set, default to the first one in the list.
      activeFarm = allFarms.first;
    }

    // Return the complete, updated session state.
    return SessionState(
      firebaseUser: firebaseUser,
      appUser: appUser,
      activeFarm: activeFarm,
      allFarms: allFarms,
    );
  });
});