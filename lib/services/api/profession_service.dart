import 'package:leadership/models/remote/prf_profession.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class ProfessionService extends BaseAPIService<PRFProfession> {
  @override
  String get endpoint => '/professions';

  @override
  PRFProfession createFromJson(Map<String, dynamic> json) {
    return PRFProfession.fromJson(json);
  }

  @override
  List<PRFProfession> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFProfession>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFProfession.fromJson)
        .toList(growable: false);
  }
}
