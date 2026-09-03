import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/models/remote/prf_class_group.dart';
import 'package:leadership/services/api/class_group_service.dart';
import 'package:leadership/services/local_storage/hive/db/class_group_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class ClassGroupResourceCubit extends ResourceCubit<PRFClassGroup> {
  ClassGroupResourceCubit({
    required ClassGroupService classGroupService,
    required ClassGroupHiveDbService hiveDbService,
  }) : super(service: classGroupService, dbService: hiveDbService);

  @override
  Future<List<PRFClassGroup>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> loadActive() {
    return loadAll(
      filters: {'status_key': PRFActiveStatus.active.apiKey},
      orderBy: 'name',
      orderDirection: 'asc',
      limit: 500,
    );
  }

  Future<void> loadActiveForInstitutionType(
    PRFInstitutionType institutionType,
  ) {
    return loadAll(
      filters: {
        'status_key': PRFActiveStatus.active.apiKey,
        'institution_type': institutionType.value,
      },
      orderBy: 'name',
      orderDirection: 'asc',
      limit: 500,
    );
  }
}
