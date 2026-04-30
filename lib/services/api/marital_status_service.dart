import 'package:leadership/models/remote/prf_marital_status.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MaritalStatusService extends BaseAPIService<PRFMaritalStatus> {
  @override
  String get endpoint => '/marital-statuses';

  @override
  PRFMaritalStatus createFromJson(Map<String, dynamic> json) {
    return PRFMaritalStatus.fromJson(json);
  }

  @override
  List<PRFMaritalStatus> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMaritalStatus>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMaritalStatus.fromJson)
        .toList(growable: false);
  }
}
