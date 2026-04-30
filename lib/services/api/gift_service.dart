import 'package:leadership/models/remote/prf_gift.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class GiftService extends BaseAPIService<PRFGift> {
  @override
  String get endpoint => '/gifts';

  @override
  PRFGift createFromJson(Map<String, dynamic> json) {
    return PRFGift.fromJson(json);
  }

  @override
  List<PRFGift> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFGift>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFGift.fromJson)
        .toList(growable: false);
  }
}
