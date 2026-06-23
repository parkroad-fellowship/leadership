import 'package:leadership/models/remote/prf_profession.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class ProfessionHiveDbService extends BaseHiveDbService<PRFProfession> {
  @override
  String get boxName => 'prf_professions';

  @override
  String getKey(PRFProfession entity) => entity.ulid;

  @override
  PRFProfession fromJson(Map<String, dynamic> json) =>
      PRFProfession.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFProfession entity) => entity.toJson();
}
