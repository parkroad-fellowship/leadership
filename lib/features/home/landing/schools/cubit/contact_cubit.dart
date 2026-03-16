import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/services/api/school_contact_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class ContactCubit extends ResourceCubit<PRFContact> {
  ContactCubit({required SchoolContactService schoolContactService})
    : super(service: schoolContactService);

  @override
  List<String> get defaultIncludes => ['contactType'];

  Future<void> loadForSchool(String schoolUlid) {
    return loadAll(filters: {'school_ulid': schoolUlid});
  }

  Future<void> createContact({
    required String name,
    required String phone,
    required String schoolUlid,
    String? email,
    String? contactTypeUlid,
  }) {
    return create(
      data: {
        'name': name,
        'phone': phone,
        'school_ulid': schoolUlid,
        if (email != null && email.isNotEmpty) 'email': email,
        if (contactTypeUlid != null && contactTypeUlid.isNotEmpty)
          'contact_type_ulid': contactTypeUlid,
      },
    );
  }

  Future<void> updateContact({
    required String ulid,
    required String name,
    required String phone,
    String? email,
    String? contactTypeUlid,
  }) {
    return update(
      id: ulid,
      data: {
        'name': name,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (contactTypeUlid != null && contactTypeUlid.isNotEmpty)
          'contact_type_ulid': contactTypeUlid,
      },
      matchById: (c) => c.ulid == ulid,
    );
  }

  Future<void> deleteContact({required String ulid}) {
    return delete(ulid: ulid, matchById: (c) => c.ulid == ulid);
  }
}
