import 'package:leadership/models/remote/prf_mission_soul.dart';
import 'package:leadership/services/api/mission_soul_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionSoulResourceCubit extends ResourceCubit<PRFMissionSoul> {
  MissionSoulResourceCubit({
    required MissionSoulService missionSoulService,
  }) : super(service: missionSoulService);

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      orderBy: 'created_at',
      orderDirection: 'desc',
      limit: 200,
    );
  }

  Future<void> createSoul({
    required String missionUlid,
    required String name,
    String? note,
  }) {
    return create(
      data: {
        'mission_ulid': missionUlid,
        'name': name,
        if (note != null && note.isNotEmpty) 'decision_note': note,
      },
    );
  }

  Future<void> updateSoul({
    required String soulUlid,
    required String name,
    String? note,
  }) {
    return update(
      id: soulUlid,
      data: {
        'name': name,
        if (note != null && note.isNotEmpty) 'decision_note': note,
      },
      matchById: (item) => item.ulid == soulUlid,
    );
  }

  Future<void> deleteSoul({required String soulUlid}) {
    return delete(
      ulid: soulUlid,
      matchById: (item) => item.ulid == soulUlid,
    );
  }
}
