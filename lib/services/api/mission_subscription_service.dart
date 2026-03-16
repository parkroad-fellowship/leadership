import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionSubscriptionService
    extends BaseAPIService<PRFMissionSubscription> {
  @override
  String get endpoint => '/mission-subscriptions';

  @override
  PRFMissionSubscription createFromJson(Map<String, dynamic> json) {
    return PRFMissionSubscription.fromJson(json);
  }

  @override
  List<PRFMissionSubscription> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMissionSubscription>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMissionSubscription.fromJson)
        .toList(growable: false);
  }
}
