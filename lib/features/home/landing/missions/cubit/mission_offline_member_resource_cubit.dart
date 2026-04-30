import 'package:leadership/models/remote/mission/prf_mission_offline_member.dart';
import 'package:leadership/models/remote/mission/prf_mission_offline_member_dto.dart';
import 'package:leadership/services/api/mission_offline_member_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionOfflineMemberResourceCubit
    extends ResourceCubit<PRFMissionOfflineMember> {
  MissionOfflineMemberResourceCubit({
    required MissionOfflineMemberService missionOfflineMemberService,
  }) : super(service: missionOfflineMemberService);

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      orderBy: 'created_at',
      orderDirection: 'desc',
      limit: 200,
    );
  }

  Future<void> addOfflineMember({
    required String missionUlid,
    required String name,
    required String phone,
  }) {
    final dto = PRFMissionOfflineMemberDTO(
      missionUlid: missionUlid,
      name: name,
      phone: phone,
    );

    return create(data: dto.toJson());
  }

  Future<void> removeOfflineMember({required String ulid}) {
    return delete(
      ulid: ulid,
      matchById: (item) => item.ulid == ulid,
    );
  }
}
