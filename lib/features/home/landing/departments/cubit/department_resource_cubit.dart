import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/services/api/department_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class DepartmentResourceCubit extends ResourceCubit<PRFDepartment> {
  DepartmentResourceCubit({required DepartmentService departmentService})
    : super(service: departmentService);

  Future<void> createDepartment({required String name}) {
    return create(data: {'name': name});
  }

  Future<void> updateDepartment({
    required String ulid,
    String? name,
    PRFActiveStatus? isActive,
  }) {
    return update(
      id: ulid,
      data: {
        'name': ?name,
        if (isActive != null) 'is_active': isActive.apiKey,
      },
      matchById: (d) => d.ulid == ulid,
    );
  }

  Future<void> deleteDepartment({required String ulid}) {
    return delete(ulid: ulid, matchById: (d) => d.ulid == ulid);
  }
}
