import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class EventHiveDbService extends BaseHiveDbService<PRFEvent> {
  @override
  String get boxName => 'prf_events';

  @override
  String getKey(PRFEvent entity) => entity.ulid;

  @override
  PRFEvent fromJson(Map<String, dynamic> json) => PRFEvent.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFEvent entity) => entity.toJson();
}
