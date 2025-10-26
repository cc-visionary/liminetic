// lib/src/features/auth/presentation/utils/auth_error_handler.dart

import 'package:firebase_auth/firebase_auth.dart';

/// A utility class to handle and translate Firebase Authentication exceptions
/// into user-friendly error messages.
class AuthErrorHandler {
  /// Takes a [FirebaseAuthException] and returns a human-readable string.
  static String getMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-not-found':
        return 'No account found with that email. Please sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
