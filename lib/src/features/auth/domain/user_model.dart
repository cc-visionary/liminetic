// lib/src/features/auth/domain/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a global user in the application. This user can be an owner
/// or member of multiple farms.
class AppUser {
  final String uid;
  final String username;
  final String? email;
  final String? activeFarmId; // The farm the user is currently viewing
  final List<String> farmIds; // A list of all farm IDs the user belongs to

  AppUser({
    required this.uid,
    required this.username,
    this.email,
    this.activeFarmId,
    required this.farmIds,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'],
      activeFarmId: data['activeFarmId'],
      farmIds: List<String>.from(data['farmIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'activeFarmId': activeFarmId,
      'farmIds': farmIds,
    };
  }
}
