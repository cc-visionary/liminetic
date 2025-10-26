// lib/src/features/farm_os/domain/farm_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Farm {
  final String id;
  final String farmName;
  final String ownerId;
  final List<String> memberIds; // List of user UIDs

  Farm({
    required this.id,
    required this.farmName,
    required this.ownerId,
    required this.memberIds,
  });

  factory Farm.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Farm(
      id: doc.id,
      farmName: data['farmName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmName': farmName,
      'ownerId': ownerId,
      'memberIds': memberIds,
    };
  }
}