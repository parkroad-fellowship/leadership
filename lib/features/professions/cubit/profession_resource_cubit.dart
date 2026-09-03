import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_profession.dart';
import 'package:leadership/models/remote/prf_profession_dto.dart';
import 'package:leadership/services/api/profession_service.dart';
import 'package:leadership/services/local_storage/hive/db/profession_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class ProfessionResourceCubit extends ResourceCubit<PRFProfession> {
  ProfessionResourceCubit({
    required ProfessionService professionService,
    required ProfessionHiveDbService hiveDbService,
  }) : super(service: professionService, dbService: hiveDbService);

  @override
  Future<List<PRFProfession>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> createProfession({required String name}) {
    return create(
      data: PRFProfessionDTO(name: name).toJson(),
    );
  }

  Future<void> updateProfession({
    required String ulid,
    String? name,
    PRFActiveStatus? isActive,
  }) {
    return update(
      id: ulid,
      data: PRFProfessionDTO(
        name: name ?? '',
        isActive: isActive,
      ).toJson(),
      matchById: (p) => p.ulid == ulid,
    );
  }

  Future<void> deleteProfession({required String ulid}) {
    return delete(ulid: ulid, matchById: (p) => p.ulid == ulid);
  }
}
