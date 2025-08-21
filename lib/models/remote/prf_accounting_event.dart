import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';

part 'prf_accounting_event.freezed.dart';
part 'prf_accounting_event.g.dart';

@freezed
abstract class PRFAccountingEvent with _$PRFAccountingEvent {
  factory PRFAccountingEvent(
    String ulid,
    String name,
    @JsonKey(name: 'due_date') DateTime dueDate,
    @JsonEnum()
    @JsonKey(name: 'responsible_desk')
    PRFResponsibleDesk responsibleDesk,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFAccountingEvent;

  factory PRFAccountingEvent.fromJson(Map<String, dynamic> json) =>
      _$PRFAccountingEventFromJson(json);
}
