import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/models/remote/prf_department_dto.dart';
import 'package:leadership/services/api/department_service.dart';
import 'package:leadership/services/local_storage/hive/db/department_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class DepartmentResourceCubit extends ResourceCubit<PRFDepartment> {
  DepartmentResourceCubit({
    required DepartmentService departmentService,
    required DepartmentHiveDbService hiveDbService,
  }) : super(service: departmentService, dbService: hiveDbService);

  @override
  Future<List<PRFDepartment>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> createDepartment({required String name}) {
    return create(
      data: PRFDepartmentDTO(name: name).toJson(),
    );
  }

  Future<void> updateDepartment({
    required String ulid,
    String? name,
    PRFActiveStatus? isActive,
  }) {
    return update(
      id: ulid,
      data: PRFDepartmentDTO(
        name: name ?? '',
        isActive: isActive,
      ).toJson(),
      matchById: (d) => d.ulid == ulid,
    );
  }

  Future<void> deleteDepartment({required String ulid}) {
    return delete(ulid: ulid, matchById: (d) => d.ulid == ulid);
  }
}
