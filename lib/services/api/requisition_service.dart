import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class RequisitionService extends BaseAPIService<PRFRequisition> {
  @override
  String get endpoint => '/requisitions';

  @override
  PRFRequisition createFromJson(Map<String, dynamic> json) {
    return PRFRequisition.fromJson(json);
  }

  @override
  List<PRFRequisition> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    return PRFRequisitionResponse.fromJson(response).data;
  }

  Future<bool> requestReview({
    required String ulid,
    required String approverUlid,
  }) async {
    try {
      await networkUtil.post(
        '$endpoint/$ulid/request-review',
        body: {
          'appointed_approver_ulid': approverUlid,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> approveRequisition({
    required String ulid,
    required String approverUlid,
    String? approvalNotes,
  }) async {
    try {
      await networkUtil.post(
        '$endpoint/$ulid/approve',
        body: {
          'approved_by_ulid': approverUlid,
          'approval_notes': ?approvalNotes,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> rejectRequisition({
    required String ulid,
    required String approverUlid,
    required String approvalNotes,
  }) async {
    try {
      await networkUtil.post(
        '$endpoint/$ulid/reject',
        body: {
          'approved_by_ulid': approverUlid,
          'approval_notes': approvalNotes,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> recallRequisition({
    required String ulid,
    required String approverUlid,
    required String approvalNotes,
  }) async {
    try {
      await networkUtil.post(
        '$endpoint/$ulid/recall',
        body: {
          'approved_by_ulid': approverUlid,
          'approval_notes': approvalNotes,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
