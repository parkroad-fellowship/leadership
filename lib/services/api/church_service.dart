import 'package:leadership/models/remote/prf_church.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class ChurchService extends BaseAPIService<PRFChurch> {
  @override
  String get endpoint => '/churches';

  @override
  PRFChurch createFromJson(Map<String, dynamic> json) {
    return PRFChurch.fromJson(json);
  }

  @override
  List<PRFChurch> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFChurch>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFChurch.fromJson)
        .toList(growable: false);
  }
}
