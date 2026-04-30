import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_payment_instruction.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';

part 'prf_requisition.freezed.dart';
part 'prf_requisition.g.dart';

@freezed
abstract class PRFRequisition with _$PRFRequisition {
  factory PRFRequisition(
    String ulid,
    @JsonKey(name: 'requisition_date') DateTime requisitionDate,
    @JsonEnum()
    @JsonKey(name: 'responsible_desk')
    PRFResponsibleDesk responsibleDesk,
    @JsonEnum()
    @JsonKey(name: 'approval_status')
    PRFApprovalStatus approvalStatus,
    @JsonKey(name: 'total_amount') int totalAmount,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {

    @JsonKey(name: 'requisition_items')
    @Default([])
    List<PRFRequisitionItem> requisitionItems,
    @JsonKey(name: 'approval_notes') String? approvalNotes,
    String? remarks,
    @JsonKey(name: 'rejected_at') DateTime? rejectedAt,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'member') PRFMember? member,
    @JsonKey(name: 'appointed_approver') PRFMember? appointedApprover,
    @JsonKey(name: 'approved_by') PRFMember? approvedBy,
    @JsonKey(name: 'accounting_event') PRFAccountingEvent? accountingEvent,
    @JsonKey(name: 'payment_instruction')
    PRFPaymentInstruction? paymentInstruction,
  }) = _PRFRequisition;

  factory PRFRequisition.fromJson(Map<String, dynamic> json) =>
      _$PRFRequisitionFromJson(json);
}

@freezed
abstract class PRFRequisitionResponse with _$PRFRequisitionResponse {
  factory PRFRequisitionResponse(
    List<PRFRequisition> data,
  ) = _PRFRequisitionResponse;

  factory PRFRequisitionResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFRequisitionResponseFromJson(json);
}
