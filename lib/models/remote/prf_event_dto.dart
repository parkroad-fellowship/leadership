import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_event_dto.freezed.dart';
part 'prf_event_dto.g.dart';

@freezed
abstract class PRFEventDTO with _$PRFEventDTO {
  factory PRFEventDTO({
    required String name,
    required String description,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_date') required String endDate,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'responsible_desk') required int responsibleDesk,
    @JsonKey(name: 'event_type') required int eventType,
  }) = _PRFEventDTO;

  factory PRFEventDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFEventDTOFromJson(json);
}
