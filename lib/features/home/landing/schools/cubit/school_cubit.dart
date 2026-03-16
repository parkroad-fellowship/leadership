import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/services/api/school_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class SchoolCubit extends ResourceCubit<PRFSchool> {
  SchoolCubit({required SchoolService schoolService})
    : super(service: schoolService);

  @override
  List<String> get defaultIncludes => ['schoolContacts.contactType'];

  Future<void> createSchool({
    required String name,
    required int totalStudents,
    required PRFInstitutionType institutionType,
    required String address,
    required double latitude,
    required double longitude,
    String? description,
    String? directions,
  }) {
    return create(
      data: {
        'name': name,
        'total_students': totalStudents,
        'institution_type': institutionType.value,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': ?description,
        'directions': ?directions,
      },
    );
  }

  Future<void> updateSchool({
    required String ulid,
    required String name,
    required int totalStudents,
    required PRFInstitutionType institutionType,
    required String address,
    required double latitude,
    required double longitude,
    String? description,
    String? directions,
  }) {
    return update(
      id: ulid,
      data: {
        'name': name,
        'total_students': totalStudents,
        'institution_type': institutionType.value,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': ?description,
        'directions': ?directions,
      },
      matchById: (s) => s.ulid == ulid,
    );
  }

  Future<void> deleteSchool({required String ulid}) {
    return delete(ulid: ulid, matchById: (s) => s.ulid == ulid);
  }
}
