import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class AllocationEntryService extends BaseAPIService<PRFAllocationEntry> {
  @override
  String get endpoint => '/allocation-entries';

  @override
  PRFAllocationEntry createFromJson(Map<String, dynamic> json) {
    return PRFAllocationEntry.fromJson(json);
  }

  @override
  List<PRFAllocationEntry> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    return PRFAllocationEntriesResponse.fromJson(response).data;
  }

  
}
