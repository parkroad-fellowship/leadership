import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MissionSubscriptionHiveDbService
    extends BaseHiveDbService<PRFMissionSubscription> {
  @override
  String get boxName => 'prf_mission_subscriptions';

  @override
  String getKey(PRFMissionSubscription entity) => entity.ulid;

  @override
  PRFMissionSubscription fromJson(Map<String, dynamic> json) =>
      PRFMissionSubscription.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMissionSubscription entity) => entity.toJson();
}
