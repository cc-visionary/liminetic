// lib/src/common_widgets/general_form_params_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:liminetic/src/features/farm_os/locations/data/location_repository.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_model.dart';
import 'package:liminetic/src/features/farm_os/locations/domain/location_template_model.dart';
import 'package:liminetic/src/features/farm_os/locations/presentation/controllers/locations_controller.dart';
import 'package:liminetic/src/features/farm_os/settings/team/domain/farm_member_model.dart';
import 'package:liminetic/src/features/farm_os/settings/team/presentation/controllers/team_controller.dart';

part 'general_form_params_provider.g.dart';

/// A data class that consolidates all common data required by various forms
/// across the application, such as the "Create Task" or "Add Location" screens.
class GeneralFormParams {
  final List<FarmMember> teamMembers;
  final List<Location> locations;
  final List<LocationTemplate> templates;

  GeneralFormParams({
    required this.teamMembers,
    required this.locations,
    required this.templates,
  });
}

/// A universal provider that fetches all common form parameters in a single,
/// efficient operation.
///
/// This replaces multiple redundant providers and serves as the single source
/// of truth for data needed in forms.
@riverpod
Future<GeneralFormParams> generalFormParams(Ref ref) async {
  final locationRepo = ref.watch(locationRepositoryProvider);

  // Use Future.wait to fetch team members and locations concurrently for better performance.
  final results = await Future.wait([
    ref.watch(teamProvider.future),
    ref.watch(rawLocationsStreamProvider.future),
  ]);

  final teamMembers = results[0] as List<FarmMember>;
  final allLocations = results[1] as List<Location>;

  // Get the filtered templates based on the active modules.
  final templates = locationRepo.getLocationTemplates();

  return GeneralFormParams(
    teamMembers: teamMembers,
    locations: allLocations,
    templates: templates,
  );
}
