import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class SchoolTermService extends BaseAPIService<PRFSchoolTerm> {
  @override
  String get endpoint => '/school-terms';

  @override
  PRFSchoolTerm createFromJson(Map<String, dynamic> json) {
    return PRFSchoolTerm.fromJson(json);
  }

  @override
  List<PRFSchoolTerm> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFSchoolTerm>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFSchoolTerm.fromJson)
        .toList(growable: false);
  }
}
