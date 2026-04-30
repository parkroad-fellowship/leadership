import 'package:leadership/models/remote/mission/prf_mission_session.dart';
import 'package:leadership/services/api/mission_session_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionSessionResourceCubit extends ResourceCubit<PRFMissionSession> {
  MissionSessionResourceCubit({
    required MissionSessionService missionSessionService,
  }) : super(service: missionSessionService);

  @override
  List<String> get defaultIncludes => [
    'facilitator',
    'speaker',
    'classGroup',
  ];

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      includes: defaultIncludes,
      orderBy: 'starts_at',
      orderDirection: 'asc',
      limit: 200,
    );
  }
}
