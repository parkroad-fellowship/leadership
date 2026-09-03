import 'package:leadership/models/remote/mission/prf_mission_ground_suggestion.dart';
import 'package:leadership/models/remote/mission/prf_mission_ground_suggestion_dto.dart';
import 'package:leadership/services/api/mission_ground_suggestion_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_ground_suggestion_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionGroundSuggestionResourceCubit
    extends ResourceCubit<PRFMissionGroundSuggestion> {
  MissionGroundSuggestionResourceCubit({
    required MissionGroundSuggestionService missionGroundSuggestionService,
    required MissionGroundSuggestionHiveDbService hiveDbService,
  }) : super(service: missionGroundSuggestionService, dbService: hiveDbService);

  @override
  Future<List<PRFMissionGroundSuggestion>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      sortBy: 'created_at',
      limit: 200,
    );
  }

  Future<void> createSuggestion({
    required String missionUlid,
    required String name,
    required String contactPerson,
    required String contactNumber,
    String? notes,
  }) {
    return create(
      data: PRFMissionGroundSuggestionDTO(
        name: name,
        contactPerson: contactPerson,
        contactNumber: contactNumber,
        notes: notes,
      ).toJson(),
    );
  }

  Future<void> updateSuggestion({
    required String suggestionUlid,
    required String name,
    required String contactPerson,
    required String contactNumber,
    String? notes,
  }) {
    return update(
      id: suggestionUlid,
      data: PRFMissionGroundSuggestionDTO(
        name: name,
        contactPerson: contactPerson,
        contactNumber: contactNumber,
        notes: notes,
      ).toJson(),
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
