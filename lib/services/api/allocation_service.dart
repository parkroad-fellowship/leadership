import 'package:leadership/models/remote/prf_allocation.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class AllocationService extends BaseAPIService<PRFAllocation> {
  @override
  String get endpoint => '/allocations';

  @override
  PRFAllocation createFromJson(Map<String, dynamic> json) {
    return PRFAllocation.fromJson(json);
  }

  @override
  List<PRFAllocation> createListFromResponse(Map<String, dynamic> response) {
    return PRFAllocationResponse.fromJson(response).data;
  }
}
