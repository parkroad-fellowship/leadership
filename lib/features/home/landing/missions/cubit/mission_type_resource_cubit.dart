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
}
