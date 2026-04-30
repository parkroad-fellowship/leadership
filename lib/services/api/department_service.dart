import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class DepartmentService extends BaseAPIService<PRFDepartment> {
  @override
  String get endpoint => '/departments';

  @override
  PRFDepartment createFromJson(Map<String, dynamic> json) {
    return PRFDepartment.fromJson(json);
  }

  @override
  List<PRFDepartment> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFDepartment>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFDepartment.fromJson)
        .toList(growable: false);
  }
}
