import 'package:leadership/models/remote/prf_class_group.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class ClassGroupService extends BaseAPIService<PRFClassGroup> {
  @override
  String get endpoint => '/class-groups';

  @override
  PRFClassGroup createFromJson(Map<String, dynamic> json) {
    return PRFClassGroup.fromJson(json);
  }

  @override
  List<PRFClassGroup> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFClassGroup>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFClassGroup.fromJson)
        .toList(growable: false);
  }
}
