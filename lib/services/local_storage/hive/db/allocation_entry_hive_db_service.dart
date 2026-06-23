

import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class AllocationEntryHiveDbService
    extends BaseHiveDbService<PRFAllocationEntry> {
  @override
  String get boxName => 'prf_allocation_entries';

  @override
  String getKey(PRFAllocationEntry entity) => entity.ulid;

  @override
  PRFAllocationEntry fromJson(Map<String, dynamic> json) =>
      PRFAllocationEntry.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFAllocationEntry entity) => entity.toJson();
}
