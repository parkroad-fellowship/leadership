import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionService extends BaseAPIService<PRFMission> {
  @override
  String get endpoint => '/missions';

  @override
  PRFMission createFromJson(Map<String, dynamic> json) {
    return PRFMission.fromJson(json);
  }

  @override
  List<PRFMission> createListFromResponse(Map<String, dynamic> response) {
    return PRFMissionsResponse.fromJson(response).data;
  }

  Future<bool> approveMission({required String ulid}) async {
    await networkUtil.post('$endpoint/$ulid/approve');
    return true;
  }

  Future<bool> rejectMission({
    required String ulid,
    String? reason,
  }) async {
    if (reason == null) {
      await networkUtil.post('$endpoint/$ulid/reject');
    } else {
      await networkUtil.post(
        '$endpoint/$ulid/reject',
        body: {'reason': reason},
      );
    }
    return true;
  }

  Future<bool> cancelMission({
    required String ulid,
    String? reason,
  }) async {
    if (reason == null) {
      await networkUtil.post('$endpoint/$ulid/cancel');
    } else {
      await networkUtil.post(
        '$endpoint/$ulid/cancel',
        body: {'reason': reason},
      );
    }
    return true;
  }

  Future<bool> completeMission({required String ulid}) async {
    await networkUtil.post('$endpoint/$ulid/complete');
    return true;
  }

  Future<bool> notifySchool({required String ulid}) async {
    await networkUtil.post('$endpoint/$ulid/notify-school');
    return true;
  }

  Future<bool> requestSchoolFeedback({required String ulid}) async {
    await networkUtil.post('$endpoint/$ulid/request-feedback');
    return true;
  }

  Future<bool> notifyWhatsappGroup({required String ulid}) async {
    await networkUtil.post('$endpoint/$ulid/notify-whatsapp');
    return true;
  }

  Future<bool> generateSummary({required String ulid}) async {
    await networkUtil.post('$endpoint/$ulid/generate-summary');
    return true;
  }

  Future<bool> uploadMediaToDrive({required String ulid}) async {
    await networkUtil.post('$endpoint/$ulid/upload-to-drive');
    return true;
  }

  Future<bool> makeZeroRequisition({required String ulid}) async {
    await networkUtil.post('$endpoint/$ulid/make-zero-requisition');
    return true;
  }

  Future<List<Map<String, dynamic>>> listMissionQuestions({
    required String missionUlid,
  }) async {
    final response = await networkUtil.get('$endpoint/$missionUlid/questions');
    final rawData = response['data'];

    if (rawData is List) {
      return rawData.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> createMissionQuestion({
    required String missionUlid,
    required String question,
  }) async {
    final response = await networkUtil.post(
      '$endpoint/$missionUlid/questions',
      body: {'question': question},
    );

    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return rawData;
    }

    return <String, dynamic>{'question': question};
  }

  Future<void> deleteMissionQuestion({
    required String missionUlid,
    required String questionUlid,
  }) async {
    await networkUtil.delete('$endpoint/$missionUlid/questions/$questionUlid');
  }
}
