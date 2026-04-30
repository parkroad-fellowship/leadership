import 'package:leadership/models/remote/mission/prf_mission_offline_member.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionOfflineMemberService
    extends BaseAPIService<PRFMissionOfflineMember> {
  @override
  String get endpoint => '/mission-offline-members';

  @override
  PRFMissionOfflineMember createFromJson(Map<String, dynamic> json) {
    return PRFMissionOfflineMember.fromJson(json);
  }

  @override
  List<PRFMissionOfflineMember> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMissionOfflineMember>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMissionOfflineMember.fromJson)
        .toList(growable: false);
  }
}
