import 'package:leadership/enums/prf_mission_role.dart';
import 'package:leadership/enums/prf_mission_subscription_status.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription_dto.dart';
import 'package:leadership/services/api/mission_subscription_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionSubscriptionResourceCubit
    extends ResourceCubit<PRFMissionSubscription> {
  MissionSubscriptionResourceCubit({
    required MissionSubscriptionService missionSubscriptionService,
  }) : super(service: missionSubscriptionService);

  @override
  List<String> get defaultIncludes => ['member', 'mission'];

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      includes: defaultIncludes,
      orderBy: 'created_at',
      orderDirection: 'desc',
      limit: 200,
    );
  }

  Future<void> subscribeMember({
    required String missionUlid,
    required String memberUlid,
  }) {
    final dto = PRFMissionSubscriptionDTO(
      missionUlid: missionUlid,
      memberUlid: memberUlid,
      status: PRFMissionSubscriptionStatus.approved,
      missionRole: PRFMissionRole.member,
    );

    return create(
      data: dto.toJson(),
      includes: defaultIncludes,
    );
  }

  Future<void> updateSubscription({
    required String subscriptionUlid,
    required PRFMissionSubscriptionDTO dto,
  }) {
    return update(
      id: subscriptionUlid,
      data: dto.toJson(),
      matchById: (item) => item.ulid == subscriptionUlid,
      includes: defaultIncludes,
    );
  }

  Future<void> unsubscribeMember({required String subscriptionUlid}) {
    return delete(
      ulid: subscriptionUlid,
      matchById: (item) => item.ulid == subscriptionUlid,
    );
  }
}
