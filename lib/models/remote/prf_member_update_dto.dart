import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_membership_entry_dto.dart';

part 'prf_member_update_dto.freezed.dart';
part 'prf_member_update_dto.g.dart';

@freezed
abstract class PRFMemberUpdateDTO with _$PRFMemberUpdateDTO {
  factory PRFMemberUpdateDTO({
    // Personal
    @JsonKey(name: 'first_name', includeIfNull: false) String? firstName,
    @JsonKey(name: 'last_name', includeIfNull: false) String? lastName,
    @JsonKey(name: 'phone_number', includeIfNull: false) String? phoneNumber,
    @JsonKey(name: 'personal_email', includeIfNull: false)
    String? personalEmail,
    @JsonKey(name: 'postal_address', includeIfNull: false)
    String? postalAddress,
    @JsonKey(includeIfNull: false) String? residence,
    @JsonKey(includeIfNull: false) String? bio,
    @JsonKey(name: 'linked_in_url', includeIfNull: false) String? linkedInUrl,

    // Spiritual
    @JsonKey(name: 'year_of_salvation', includeIfNull: false)
    int? yearOfSalvation,
    @JsonKey(name: 'church_volunteer', includeIfNull: false)
    bool? churchVolunteer,
    @JsonKey(includeIfNull: false) String? pastor,
    @JsonKey(name: 'church_ulid', includeIfNull: false) String? churchUlid,

    // Professional
    @JsonKey(name: 'profession_ulid', includeIfNull: false)
    String? professionUlid,
    @JsonKey(name: 'profession_institution', includeIfNull: false)
    String? professionInstitution,
    @JsonKey(name: 'profession_location', includeIfNull: false)
    String? professionLocation,
    @JsonKey(name: 'profession_contact', includeIfNull: false)
    String? professionContact,

    // Demographics
    @JsonKey(includeIfNull: false) int? gender,
    @JsonKey(name: 'marital_status_ulid', includeIfNull: false)
    String? maritalStatusUlid,

    // Relationships
    @JsonKey(name: 'department_ulids', includeIfNull: false)
    List<String>? departmentUlids,
    @JsonKey(name: 'gift_ulids', includeIfNull: false) List<String>? giftUlids,
    @JsonKey(includeIfNull: false) List<PRFMembershipEntryDTO>? memberships,
  }) = _PRFMemberUpdateDTO;

  factory PRFMemberUpdateDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMemberUpdateDTOFromJson(json);
}
