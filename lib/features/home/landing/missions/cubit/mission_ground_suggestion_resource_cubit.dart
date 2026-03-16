import 'package:leadership/models/remote/mission/prf_mission_ground_suggestion.dart';
import 'package:leadership/services/api/mission_ground_suggestion_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionGroundSuggestionResourceCubit
    extends ResourceCubit<PRFMissionGroundSuggestion> {
  MissionGroundSuggestionResourceCubit({
    required MissionGroundSuggestionService missionGroundSuggestionService,
  }) : super(service: missionGroundSuggestionService);

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      orderBy: 'created_at',
      orderDirection: 'desc',
      limit: 200,
    );
  }

  Future<void> createSuggestion({
    required String missionUlid,
    required String suggestion,
  }) {
    return create(
      data: {
        'mission_ulid': missionUlid,
        'suggestion': suggestion,
      },
    );
  }

  Future<void> updateSuggestion({
    required String suggestionUlid,
    required String suggestion,
  }) {
    return update(
      id: suggestionUlid,
      data: {'suggestion': suggestion},
      matchById: (item) => item.ulid == suggestionUlid,
    );
  }

  Future<void> deleteSuggestion({required String suggestionUlid}) {
    return delete(
      ulid: suggestionUlid,
      matchById: (item) => item.ulid == suggestionUlid,
    );
  }
}
