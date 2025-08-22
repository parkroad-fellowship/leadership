import 'package:leadership/models/remote/prf_mission.dart';
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
}
