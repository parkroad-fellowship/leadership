import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_member.dart';

part 'prf_allocation_entry.freezed.dart';
part 'prf_allocation_entry.g.dart';

@freezed
abstract class PRFAllocationEntry with _$PRFAllocationEntry {
  factory PRFAllocationEntry(
    String ulid,
    @JsonEnum() @JsonKey(name: 'entry_type') PRFEntryType entryType,
    int amount,
    @JsonKey(name: 'unit_cost') int unitCost,
    int quantity,
    int charge,
    String narration,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @JsonKey(name: 'charge_type') PRFChargeType? chargeType,
    @JsonKey(name: 'confirmation_message') String? confirmationMessage,
    @JsonKey(name: 'accounting_event') PRFAccountingEvent? accountingEvent,
    @JsonKey(name: 'expense_category') PRFExpenseCategory? expenseCategory,
    PRFMember? member,
    @Default([]) List<PRFMedia> receipts,
  }) = _PRFAllocationEntry;

  factory PRFAllocationEntry.fromJson(Map<String, dynamic> json) =>
      _$PRFAllocationEntryFromJson(json);
}

@freezed
abstract class PRFAllocationEntriesResponse
    with _$PRFAllocationEntriesResponse {
  factory PRFAllocationEntriesResponse(List<PRFAllocationEntry> data) =
      _PRFAllocationEntriesResponse;

  factory PRFAllocationEntriesResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFAllocationEntriesResponseFromJson(json);
}
