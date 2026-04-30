import 'package:leadership/models/remote/mission/prf_soul.dart';
import 'package:leadership/models/remote/mission/prf_soul_dto.dart';
import 'package:leadership/services/api/soul_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class SoulResourceCubit extends ResourceCubit<PRFSoul> {
  SoulResourceCubit({
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
    required PRFSoulDTO dto,
  }) {
    return create(
      data: dto.toJson(),
    );
  }

  Future<void> updateSoul({
    required String soulUlid,
    required PRFSoulDTO dto,
  }) {
    return update(
      id: soulUlid,
      data: dto.toJson(),
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
