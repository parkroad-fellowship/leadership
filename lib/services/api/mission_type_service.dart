import 'package:leadership/models/remote/prf_mission_type.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionTypeService extends BaseAPIService<PRFMissionType> {
  @override
  String get endpoint => '/mission-types';

  @override
  PRFMissionType createFromJson(Map<String, dynamic> json) {
    return PRFMissionType.fromJson(json);
  }

  @override
  List<PRFMissionType> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMissionType>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMissionType.fromJson)
        .toList(growable: false);
  }
}
