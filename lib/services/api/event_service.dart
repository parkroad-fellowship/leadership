import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class EventService extends BaseAPIService<PRFEvent> {
  @override
  String get endpoint => '/events';

  @override
  PRFEvent createFromJson(Map<String, dynamic> json) {
    return PRFEvent.fromJson(json);
  }

  @override
  List<PRFEvent> createListFromResponse(Map<String, dynamic> response) {
    return PRFEventResponse.fromJson(response).data;
  }
}
