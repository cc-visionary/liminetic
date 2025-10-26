// lib/src/features/farm_os/data/farm_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/features/farm_os/team/domain/farm_member_model.dart';
import '../domain/farm_model.dart';

class FarmRepository {
  final FirebaseFirestore _firestore;

  FarmRepository(this._firestore);

  // Create a new farm and set it as the user's active farm
  Future<void> createFarm({
    required String farmName,
    required String ownerId,
  }) async {
    try {
      // Create the farm document
      DocumentReference farmDocRef = await _firestore.collection('farms').add({
        'farmName': farmName,
        'ownerId': ownerId,
        'memberIds': [ownerId], // The owner is the first member
      });

      // Update the user's document with the activeFarmId
      await _firestore.collection('users').doc(ownerId).update({
        'activeFarmId': farmDocRef.id,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Method to get a specific farm by its ID
  Future<Farm?> getFarm(String farmId) async {
    try {
      final doc = await _firestore.collection('farms').doc(farmId).get();
      if (doc.exists) {
        return Farm.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a list of Farm documents based on a list of farm IDs.
  /// Uses a Firestore 'in' query for efficiency.
  Future<List<Farm>> getFarmsByIds(List<String> farmIds) async {
    if (farmIds.isEmpty) {
      return [];
    }
    // Firestore 'in' queries are limited to 30 items per request.
    // For this app, that is a reasonable limit.
    final querySnapshot = await _firestore
        .collection('farms')
        .where(FieldPath.documentId, whereIn: farmIds)
        .get();

    return querySnapshot.docs.map((doc) => Farm.fromFirestore(doc)).toList();
  }

  /// Fetches a stream of members for a given farm.
  Stream<List<FarmMember>> getFarmMembers(String farmId) {
    return _firestore
        .collection('farms')
        .doc(farmId)
        .collection('members')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FarmMember.fromFirestore(doc))
              .toList(),
        );
  }

  /// Updates the details of a specific farm.
  Future<void> updateFarmDetails({
    required String farmId,
    required String farmName,
    // Add other fields like address later
  }) async {
    await _firestore.collection('farms').doc(farmId).update({
      'farmName': farmName,
    });
  }

  Future<void> updateActiveModules({
    required String farmId,
    required List<String> activeModules,
  }) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .update({'activeModules': activeModules});
  }
}

// Provider for FarmRepository
final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepository(FirebaseFirestore.instance);
});
