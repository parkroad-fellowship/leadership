import 'package:leadership/models/remote/mission/prf_soul.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionSoulService extends BaseAPIService<PRFSoul> {
  @override
  String get endpoint => '/souls';

  @override
  PRFSoul createFromJson(Map<String, dynamic> json) {
    return PRFSoul.fromJson(json);
  }

  @override
  List<PRFSoul> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFSoul>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFSoul.fromJson)
        .toList(growable: false);
  }
}
