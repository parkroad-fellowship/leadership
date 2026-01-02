import 'dart:convert';

import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_allocation_entry_dto.dart';
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

  Future<PRFAllocationEntry> addToken({
    required PRFAllocationTokenEntryDTO data,
  }) async {
    try {
      final response = await networkUtil.post(
        '$endpoint/add-token',
        body: json.encode(data.toJson()),
      );

      return PRFAllocationEntry.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReceipt({
    required String allocationEntryUlid,
    required String mediaUuid,
  }) async {
    try {
      await networkUtil.delete(
        '$endpoint/$allocationEntryUlid/media/$mediaUuid',
        apiVersion: 'v2',
      );
    } catch (e) {
      rethrow;
    }
  }
}
