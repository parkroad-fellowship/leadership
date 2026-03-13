import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_mission_type.dart';
import 'package:leadership/services/api/mission_type_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionTypeResourceCubit extends ResourceCubit<PRFMissionType> {
  MissionTypeResourceCubit({required MissionTypeService missionTypeService})
    : super(service: missionTypeService);

  Future<void> loadActive() {
    return loadAll(
      filters: {'status_key': PRFActiveStatus.active.apiKey},
      orderBy: 'name',
      orderDirection: 'asc',
      limit: 200,
    );
  }

  Future<void> createMissionType({required String name}) {
    return create(data: {'name': name});
  }

  Future<void> updateMissionType({
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
      matchById: (mt) => mt.ulid == ulid,
    );
  }

  Future<void> deleteMissionType({required String ulid}) {
    return delete(ulid: ulid, matchById: (mt) => mt.ulid == ulid);
  }
}
