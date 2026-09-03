import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/models/remote/prf_school_term_dto.dart';
import 'package:leadership/services/api/school_term_service.dart';
import 'package:leadership/services/local_storage/hive/db/school_term_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class SchoolTermResourceCubit extends ResourceCubit<PRFSchoolTerm> {
  SchoolTermResourceCubit({
    required SchoolTermService schoolTermService,
    required SchoolTermHiveDbService hiveDbService,
  }) : super(service: schoolTermService, dbService: hiveDbService);

  @override
  Future<List<PRFSchoolTerm>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

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
    return create(
      data: PRFSchoolTermDTO(name: name, year: year).toJson(),
    );
  }

  Future<void> updateSchoolTerm({
    required String ulid,
    String? name,
    int? year,
    PRFActiveStatus? isActive,
  }) {
    return update(
      id: ulid,
      data: PRFSchoolTermDTO(
        name: name ?? '',
        year: year ?? 0,
        isActive: isActive,
      ).toJson(),
      matchById: (st) => st.ulid == ulid,
    );
  }

  Future<void> deleteSchoolTerm({required String ulid}) {
    return delete(ulid: ulid, matchById: (st) => st.ulid == ulid);
  }
}
