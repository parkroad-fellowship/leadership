import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class SchoolContactService extends BaseAPIService<PRFContact> {
  @override
  String get endpoint => '/school-contacts';

  @override
  PRFContact createFromJson(Map<String, dynamic> json) {
    return PRFContact.fromJson(json);
  }

  @override
  List<PRFContact> createListFromResponse(Map<String, dynamic> response) {
    return PRFContactResponse.fromJson(response).data;
  }
}
