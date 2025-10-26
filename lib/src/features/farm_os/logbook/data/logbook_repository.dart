// lib/src/features/farm_os/logbook/data/logbook_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/features/farm_os/logbook/domain/log_entry_model.dart';

/// Repository for managing logbook data in Firestore.
class LogbookRepository {
  final FirebaseFirestore _firestore;
  LogbookRepository(this._firestore);

  /// Gets a real-time stream of all log entries for a farm, ordered by timestamp.
  Stream<List<LogEntry>> getLogsStream(String farmId) {
    return _firestore
        .collection('farms')
        .doc(farmId)
        .collection('logbook')
        .orderBy('timestamp', descending: true) // Show newest logs first
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => LogEntry.fromFirestore(doc)).toList(),
        );
  }

  /// Adds a new, fully-formed log entry document to the subcollection.
  /// The controller is responsible for creating the LogEntry object with the correct payload.
  Future<void> addLogEntry(String farmId, LogEntry log) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('logbook')
        .add(log.toMap());
  }

  /// Updates a specific log entry document.
  Future<void> updateLogEntry(
    String farmId,
    String logId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('logbook')
        .doc(logId)
        .update(data);
  }

  /// Deletes a specific log entry document.
  Future<void> deleteLogEntry(String farmId, String logId) async {
    await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('logbook')
        .doc(logId)
        .delete();
  }
}

/// Riverpod provider for the LogbookRepository.
final logbookRepositoryProvider = Provider<LogbookRepository>((ref) {
  return LogbookRepository(FirebaseFirestore.instance);
});
