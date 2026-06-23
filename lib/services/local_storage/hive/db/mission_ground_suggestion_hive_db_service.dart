import 'package:leadership/models/remote/mission/prf_mission_ground_suggestion.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MissionGroundSuggestionHiveDbService
    extends BaseHiveDbService<PRFMissionGroundSuggestion> {
  @override
  String get boxName => 'prf_mission_ground_suggestions';

  @override
  String getKey(PRFMissionGroundSuggestion entity) => entity.ulid;

  @override
  PRFMissionGroundSuggestion fromJson(Map<String, dynamic> json) =>
      PRFMissionGroundSuggestion.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMissionGroundSuggestion entity) =>
      entity.toJson();
}
