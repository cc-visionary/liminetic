// lib/src/features/farm_os/team/domain/farm_member_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's role and permissions within a specific farm.
class FarmMember {
  final String uid;
  final String username;
  final String? email;
  final String role; // A descriptive role name, e.g., "Field Worker"
  final Map<String, bool> permissions;

  FarmMember({
    required this.uid,
    required this.username,
    this.email,
    required this.role,
    required this.permissions,
  });

  factory FarmMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmMember(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'],
      role: data['role'] ?? 'Member',
      permissions: Map<String, bool>.from(data['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
      'permissions': permissions,
    };
  }
}
