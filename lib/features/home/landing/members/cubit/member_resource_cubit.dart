import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/api/member_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MemberResourceCubit extends ResourceCubit<PRFMember> {
  MemberResourceCubit({required MemberService memberService})
    : super(service: memberService);

  @override
  List<String> get defaultIncludes => [
    'profession',
    'maritalStatus',
    'church',
    'profilePicture',
  ];

  Future<void> updateMember({
    required String ulid,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? personalEmail,
    String? postalAddress,
    String? residence,
    String? bio,
    String? linkedInUrl,
    int? yearOfSalvation,
    bool? churchVolunteer,
    String? pastor,
    String? churchUlid,
    String? professionUlid,
    String? professionInstitution,
    String? professionLocation,
    String? professionContact,
    int? gender,
    String? maritalStatusUlid,
  }) {
    return update(
      id: ulid,
      data: {
        'first_name': ?firstName,
        'last_name': ?lastName,
        'phone_number': ?phoneNumber,
        'personal_email': ?personalEmail,
        'postal_address': ?postalAddress,
        'residence': ?residence,
        'bio': ?bio,
        'linked_in_url': ?linkedInUrl,
        'year_of_salvation': ?yearOfSalvation,
        'church_volunteer': ?churchVolunteer,
        'pastor': ?pastor,
        'church_ulid': ?churchUlid,
        'profession_ulid': ?professionUlid,
        'profession_institution': ?professionInstitution,
        'profession_location': ?professionLocation,
        'profession_contact': ?professionContact,
        'gender': ?gender,
        'marital_status_ulid': ?maritalStatusUlid,
      },
      matchById: (m) => m.ulid == ulid,
    );
  }
}
