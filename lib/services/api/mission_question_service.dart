import 'package:leadership/models/remote/mission/prf_mission_question.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionQuestionService extends BaseAPIService<PRFMissionQuestion> {
  @override
  String get endpoint => '/mission-questions';

  @override
  PRFMissionQuestion createFromJson(Map<String, dynamic> json) {
    return PRFMissionQuestion.fromJson(json);
  }

  @override
  List<PRFMissionQuestion> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMissionQuestion>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMissionQuestion.fromJson)
        .toList(growable: false);
  }
}
