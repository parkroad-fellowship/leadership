import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/services/api/school_term_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class SchoolTermResourceCubit extends ResourceCubit<PRFSchoolTerm> {
  SchoolTermResourceCubit({required SchoolTermService schoolTermService})
    : super(service: schoolTermService);

  Future<void> loadActive() {
    return loadAll(
      filters: {'status_key': PRFActiveStatus.active.apiKey},

      orderBy: 'created_at',
      orderDirection: 'desc',
      limit: 200,
    );
  }

  Future<void> createSchoolTerm({
    required String name,
    required int year,
  }) {
    return create(data: {'name': name, 'year': year});
  }

  Future<void> updateSchoolTerm({
    required String ulid,
    String? name,
    int? year,
    PRFActiveStatus? isActive,
  }) {
    return update(
      id: ulid,
      data: {
        'name': ?name,
        'year': ?year,
        if (isActive != null) 'is_active': isActive.apiKey,
      },
      matchById: (st) => st.ulid == ulid,
    );
  }

  Future<void> deleteSchoolTerm({required String ulid}) {
    return delete(ulid: ulid, matchById: (st) => st.ulid == ulid);
  }
}
