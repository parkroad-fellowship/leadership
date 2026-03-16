import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/prf_church.dart';
import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/models/remote/prf_gift.dart';
import 'package:leadership/models/remote/prf_group_member.dart';
import 'package:leadership/models/remote/prf_marital_status.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_membership.dart';
import 'package:leadership/models/remote/prf_profession.dart';

part 'prf_member.freezed.dart';
part 'prf_member.g.dart';

@freezed
abstract class PRFMember with _$PRFMember {
  factory PRFMember(
    String ulid,
    @JsonKey(name: 'first_name') String firstName,
    @JsonKey(name: 'last_name') String lastName,
    @JsonKey(name: 'full_name') String fullName,
    String email, {
    @JsonKey(name: 'church_volunteer') required bool churchVolunteer,
    @JsonKey(name: 'accept_terms') required bool acceptTerms,
    @JsonKey(name: 'approved') required bool approved,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'postal_address') String? postalAddress,
    String? residence,
    String? pastor,
    int? gender,
    @JsonKey(name: 'year_of_salvation') int? yearOfSalvation,
    @JsonKey(name: 'profession_institution') String? professionInstitution,
    @JsonKey(name: 'profession_location') String? professionLocation,
    @JsonKey(name: 'profession_contact') String? professionContact,
    String? bio,
    @JsonKey(name: 'linked_in_url') String? linkedInUrl,
    PRFUser? user,
    @JsonKey(name: 'marital_status') PRFMaritalStatus? maritalStatus,
    PRFProfession? profession,
    PRFChurch? church,
    @JsonKey(name: 'group_members') List<PRFGroupMember>? groupMembers,
    @Default([]) List<PRFMembership> memberships,
    @Default([]) List<PRFGift> gifts,
    @Default([]) List<PRFDepartment> departments,
    @JsonKey(name: 'profile_picture') PRFMedia? profilePicture,
  }) = _PRFMember;

  factory PRFMember.fromJson(Map<String, dynamic> json) =>
      _$PRFMemberFromJson(json);
}

@freezed
abstract class PRFMembersResponse with _$PRFMembersResponse {
  factory PRFMembersResponse(
    List<PRFMember> data,
  ) = _PRFMembersResponse;

  factory PRFMembersResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFMembersResponseFromJson(json);
}
