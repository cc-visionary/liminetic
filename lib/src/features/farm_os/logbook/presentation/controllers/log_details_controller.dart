// lib/src/features/farm_os/logbook/presentation/controllers/log_details_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';
import 'package:liminetic/src/features/farm_os/settings/team/presentation/controllers/team_controller.dart';

part 'log_details_controller.g.dart';

/// A provider to resolve an assignee's ID to their username.
/// The `.family` modifier allows us to pass in the ID.
@riverpod
Future<String> assigneeName(Ref ref, String? assigneeId) async {
  if (assigneeId == null) return 'Unassigned';
  // Await the future from the teamProvider to get the list of members.
  final team = await ref.watch(teamProvider.future);
  try {
    return team.firstWhere((member) => member.uid == assigneeId).username;
  } catch (e) {
    return 'Unknown User';
  }
}

/// A provider that resolves a list of location IDs to a comma-separated string of names.
@riverpod
Future<String> locationNames(
  Ref ref,
  List<String> locationIds,
) async {
  if (locationIds.isEmpty) return 'None';
  final locations = await ref.watch(rawLocationsStreamProvider.future);
  final names = locationIds.map((id) {
    try {
      return locations.firstWhere((loc) => loc.id == id).name;
    } catch (e) {
      return 'Unknown';
    }
  }).toList();
  return names.join(', ');
}
