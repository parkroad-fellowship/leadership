import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_requisition.dart';

part 'prf_allocation.freezed.dart';
part 'prf_allocation.g.dart';

@freezed
abstract class PRFAllocation with _$PRFAllocation {
  factory PRFAllocation(
    String ulid,
    int amount,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @JsonKey(name: 'accounting_event') PRFAccountingEvent? accountingEvent,
    PRFRequisition? requisition,
    @Default([])
    @JsonKey(name: 'allocation_entries')
    List<PRFAllocationEntry> allocationEntries,
  }) = _PRFAllocation;

  factory PRFAllocation.fromJson(Map<String, dynamic> json) =>
      _$PRFAllocationFromJson(json);
}

@freezed
abstract class PRFAllocationResponse with _$PRFAllocationResponse {
  factory PRFAllocationResponse(List<PRFAllocation> data) =
      _PRFAllocationResponse;

  factory PRFAllocationResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFAllocationResponseFromJson(json);
}
