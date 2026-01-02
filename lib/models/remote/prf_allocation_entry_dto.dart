import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';

part 'prf_allocation_entry_dto.freezed.dart';
part 'prf_allocation_entry_dto.g.dart';

@freezed
abstract class PRFAllocationEntryDTO with _$PRFAllocationEntryDTO {
  factory PRFAllocationEntryDTO({
    @JsonKey(name: 'accounting_event_ulid') required String accountingEventUlid,
    @JsonKey(name: 'expense_category_ulid') required String expenseCategoryUlid,
    @JsonKey(name: 'member_ulid') required String memberUlid,
    @JsonEnum() @JsonKey(name: 'entry_type') required PRFEntryType entryType,
    @JsonEnum() @JsonKey(name: 'charge_type') required PRFChargeType chargeType,
    @JsonKey(name: 'charge') required int charge,
    @JsonKey(name: 'unit_cost') required int unitCost,
    @JsonKey(name: 'confirmation_message') required String confirmationMessage,
    required int quantity,
    required String narration,
  }) = _PRFAllocationEntryDTO;

  factory PRFAllocationEntryDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFAllocationEntryDTOFromJson(json);
}

@freezed
abstract class PRFAllocationTokenEntryDTO with _$PRFAllocationTokenEntryDTO {
  factory PRFAllocationTokenEntryDTO({
    @JsonKey(name: 'accounting_event_ulid') required String accountingEventUlid,
    @JsonKey(name: 'member_ulid') required String memberUlid,
    @JsonEnum() @JsonKey(name: 'entry_type') required PRFEntryType entryType,
    @JsonKey(name: 'unit_cost') required int unitCost,
    @JsonKey(name: 'confirmation_message') required String confirmationMessage,
    required String narration,
  }) = _PRFAllocationTokenEntryDTO;

  factory PRFAllocationTokenEntryDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFAllocationTokenEntryDTOFromJson(json);
}
