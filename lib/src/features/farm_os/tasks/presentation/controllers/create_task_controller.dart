// lib/src/features/farm_os/tasks/presentation/controllers/create_task_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';
import 'package:liminetic/src/features/farm_os/settings/team/domain/farm_member_model.dart';
import 'package:liminetic/src/features/farm_os/settings/team/presentation/controllers/team_controller.dart';

part 'create_task_controller.g.dart';

/// A helper class to hold the data needed for the Create Task form.
class CreateTaskFormParams {
  final List<FarmMember> teamMembers;
  final List<Location> locations;

  CreateTaskFormParams({required this.teamMembers, required this.locations});
}

/// A provider that fetches all team members and locations to populate the
/// dropdown menus in the 'Create Task' screen.
@riverpod
Future<CreateTaskFormParams> createTaskFormParams(
  Ref ref,
) async {
  // Fetch a snapshot of the current team members and locations.
  final teamMembers = await ref.watch(teamProvider.future);
  final locations = await ref.watch(rawLocationsStreamProvider.future);

  return CreateTaskFormParams(teamMembers: teamMembers, locations: locations);
}
