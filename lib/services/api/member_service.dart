import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MemberService extends BaseAPIService<PRFMember> {
  @override
  String get endpoint => '/members';

  @override
  PRFMember createFromJson(Map<String, dynamic> json) {
    return PRFMember.fromJson(json);
  }

  @override
  List<PRFMember> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    return PRFMembersResponse.fromJson(response).data;
  }
}
