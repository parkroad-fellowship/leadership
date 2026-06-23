import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_marital_status.dart';
import 'package:leadership/services/api/marital_status_service.dart';
import 'package:leadership/services/local_storage/hive/db/marital_status_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MaritalStatusResourceCubit extends ResourceCubit<PRFMaritalStatus> {
  MaritalStatusResourceCubit({
    required MaritalStatusService maritalStatusService,
    required MaritalStatusHiveDbService hiveDbService,
  }) : super(service: maritalStatusService, dbService: hiveDbService);

  @override
  Future<List<PRFMaritalStatus>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> createMaritalStatus({required String name}) {
    return create(data: {'name': name});
  }

  Future<void> updateMaritalStatus({
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
      matchById: (ms) => ms.ulid == ulid,
    );
  }

  Future<void> deleteMaritalStatus({required String ulid}) {
    return delete(ulid: ulid, matchById: (ms) => ms.ulid == ulid);
  }
}
