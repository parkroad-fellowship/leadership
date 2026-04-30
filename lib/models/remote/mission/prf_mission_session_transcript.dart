import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_media.dart';

part 'prf_mission_session_transcript.freezed.dart';
part 'prf_mission_session_transcript.g.dart';

@freezed
abstract class PRFMissionSessionTranscript with _$PRFMissionSessionTranscript {
  factory PRFMissionSessionTranscript(
    String ulid, {
    @Default('') @JsonKey(name: 'transcription_content') String content,
    PRFMedia? media,
  }) = _PRFMissionSessionTranscript;

  factory PRFMissionSessionTranscript.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionSessionTranscriptFromJson(json);
}
