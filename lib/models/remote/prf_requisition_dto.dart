import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';

part 'prf_requisition_dto.freezed.dart';
part 'prf_requisition_dto.g.dart';

@freezed
abstract class PRFRequisitionDTO with _$PRFRequisitionDTO {
  factory PRFRequisitionDTO({
    @JsonKey(name: 'member_ulid') required String memberUlid,
    @JsonKey(name: 'accounting_event_ulid') required String accountingEventUlid,
    @JsonKey(name: 'requisition_date') required DateTime requisitionDate,
    @JsonEnum()
    @JsonKey(name: 'responsible_desk')
    required PRFResponsibleDesk responsibleDesk,
    required String remarks,
  }) = _PRFRequisitionDTO;

  factory PRFRequisitionDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFRequisitionDTOFromJson(json);
}
