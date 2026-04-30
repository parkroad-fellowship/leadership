import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class ContactTypeService extends BaseAPIService<PRFContactType> {
  @override
  String get endpoint => '/contact-types';

  @override
  PRFContactType createFromJson(Map<String, dynamic> json) {
    return PRFContactType.fromJson(json);
  }

  @override
  List<PRFContactType> createListFromResponse(Map<String, dynamic> response) {
    return PRFContactTypeResponse.fromJson(response).data;
  }
}
