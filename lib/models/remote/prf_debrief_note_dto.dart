import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_debrief_note_dto.freezed.dart';
part 'prf_debrief_note_dto.g.dart';

@freezed
abstract class PRFDebriefNoteDTO with _$PRFDebriefNoteDTO {
  factory PRFDebriefNoteDTO({
    @JsonKey(name: 'mission_ulid') required String missionUlid,
    @JsonKey(name: 'note') required String note,
  }) = _PRFDebriefNoteDTO;

  factory PRFDebriefNoteDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFDebriefNoteDTOFromJson(json);
}
