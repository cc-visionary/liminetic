// lib/src/features/auth/data/auth_repository.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/features/farm_os/team/domain/farm_member_model.dart';
import '../domain/user_model.dart';

/// A repository for handling all authentication and user management tasks.
/// It interacts with Firebase Auth and the 'users' collection in Firestore.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  /// A stream that emits the current Firebase user when the auth state changes.
  /// Used to determine if a user is logged in or out in real-time.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the currently signed-in Firebase user, if any.
  User? get currentUser => _auth.currentUser;

  /// Signs up a new primary user (farm owner) and creates their first farm.
  /// This is a transactional operation to ensure data consistency.
  Future<UserCredential> signUpAndCreateFarm({
    required String email,
    required String password,
    required String username,
    required String farmName,
  }) async {
    // 1. Check if the chosen username is already taken.
    final usernameQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (usernameQuery.docs.isNotEmpty) {
      throw Exception('This username is already taken. Please choose another.');
    }

    // 2. Create the user in Firebase Authentication.
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user == null) {
      throw Exception('User creation failed. Please try again.');
    }

    // 3. Create the farm and user documents in a single atomic transaction.
    final farmDocRef = _firestore.collection('farms').doc();
    final userDocRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      // Create the Farm document.
      transaction.set(farmDocRef, {
        'farmName': farmName,
        'ownerId': user.uid,
      });

      // Create the AppUser document.
      final newUser = AppUser(
        uid: user.uid,
        username: username,
        email: email,
        farmIds: [farmDocRef.id], // Add the new farm to their list
        activeFarmId: farmDocRef.id, // Set it as the currently active farm
      );
      transaction.set(userDocRef, newUser.toMap());
    });

    return userCredential;
  }

  /// Creates a new farm for an existing, authenticated user.
  ///
  /// This is a transactional operation that:
  /// 1. Creates the new farm document.
  /// 2. Adds the new farm's ID to the user's `farmIds` list.
  /// 3. Sets the new farm as the user's `activeFarmId`.
  Future<void> createNewFarm({
    required String farmName,
    required String ownerId,
  }) async {
    final farmDocRef = _firestore.collection('farms').doc();
    final userDocRef = _firestore.collection('users').doc(ownerId);

    // Use a transaction to ensure both writes succeed or fail together.
    await _firestore.runTransaction((transaction) async {
      // Create the new farm document.
      transaction.set(farmDocRef, {
        'farmName': farmName,
        'ownerId': ownerId,
      });

      // Update the user's document.
      transaction.update(userDocRef, {
        'farmIds': FieldValue.arrayUnion([farmDocRef.id]),
        'activeFarmId': farmDocRef.id,
      });
    });
  }

  /// Creates a sub-user account with a username and password (no real email).
  /// This method uses a temporary Firebase app instance to avoid logging out the admin.
  Future<void> createSubUser({
    required String username,
    required String password,
    required String farmId,
    required String role,
    required Map<String, bool> permissions,
  }) async {
    final usernameQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (usernameQuery.docs.isNotEmpty) {
      throw Exception('Username is already taken.');
    }

    // Generate a unique, non-functional "proxy email" for Firebase Auth.
    final proxyEmail = '$username@$farmId.liminetic.local';

    // Use a temporary app instance to create the user without signing out the admin.
    final tempAppName = 'temp_user_creation_${DateTime.now().millisecondsSinceEpoch}';
    final tempApp = await Firebase.initializeApp(name: tempAppName, options: Firebase.app().options);
    final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

    try {
      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: proxyEmail,
        password: password,
      );
      final newUserUid = userCredential.user!.uid;

      // Create the global AppUser document for the new sub-user.
      final newAppUser = AppUser(
        uid: newUserUid,
        username: username,
        activeFarmId: farmId,
        farmIds: [farmId], // The sub-user belongs to this farm.
      );
      await _firestore.collection('users').doc(newUserUid).set(newAppUser.toMap());

      // Create the FarmMember document in the farm's subcollection.
      final newFarmMember = FarmMember(
        uid: newUserUid,
        username: username,
        role: role,
        permissions: permissions,
      );
      await _firestore
          .collection('farms')
          .doc(farmId)
          .collection('members')
          .doc(newUserUid)
          .set(newFarmMember.toMap());
    } finally {
      // Clean up the temporary app instance.
      await tempApp.delete();
    }
  }

  /// Signs in a user with either their email or username.
  Future<UserCredential> signIn({
    required String loginIdentifier,
    required String password,
  }) async {
    try {
      String email = loginIdentifier;
      // If the identifier is not an email, assume it's a username and look it up.
      if (!loginIdentifier.contains('@')) {
        final userQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: loginIdentifier)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          throw Exception('User not found. Please check the username and try again.');
        }
        // This will find both real emails and our generated proxy emails.
        final userData = userQuery.docs.first.data();
        email = userData['email'] ?? '$loginIdentifier@${userData['activeFarmId']}.liminetic.local';
      }

      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Fetches a user's AppUser document from Firestore by their UID.
  Future<AppUser?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  /// Updates a user's profile information (currently only username).
  Future<void> updateUserProfile({
    required String uid,
    required String username,
  }) async {
    await _firestore.collection('users').doc(uid).update({'username': username});
  }
}

/// The Riverpod provider for the AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});