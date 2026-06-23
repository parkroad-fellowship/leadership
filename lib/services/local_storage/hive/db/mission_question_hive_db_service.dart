import 'package:leadership/models/remote/mission/prf_mission_question.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MissionQuestionHiveDbService
    extends BaseHiveDbService<PRFMissionQuestion> {
  @override
  String get boxName => 'prf_mission_questions';

  @override
  String getKey(PRFMissionQuestion entity) => entity.ulid;

  @override
  PRFMissionQuestion fromJson(Map<String, dynamic> json) =>
      PRFMissionQuestion.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMissionQuestion entity) => entity.toJson();
}
