import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';

part 'prf_debrief_note.freezed.dart';
part 'prf_debrief_note.g.dart';

@freezed
abstract class PRFDebriefNote with _$PRFDebriefNote {
  factory PRFDebriefNote(
    String ulid,
    String note,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    PRFMission? mission,
  }) = _PRFDebriefNote;

  factory PRFDebriefNote.fromJson(Map<String, dynamic> json) =>
      _$PRFDebriefNoteFromJson(json);
}

@freezed
abstract class PRFDebriefNoteResponse with _$PRFDebriefNoteResponse {
  const factory PRFDebriefNoteResponse({required List<PRFDebriefNote> data}) =
      _PRFDebriefNoteResponse;

  factory PRFDebriefNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFDebriefNoteResponseFromJson(json);
}
