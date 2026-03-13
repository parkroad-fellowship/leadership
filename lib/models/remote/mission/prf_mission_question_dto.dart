import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_mission_question_dto.freezed.dart';
part 'prf_mission_question_dto.g.dart';

@freezed
abstract class PRFMissionQuestionDTO with _$PRFMissionQuestionDTO {
  factory PRFMissionQuestionDTO({
    @JsonKey(name: 'question') required String question,
    @JsonKey(name: 'mission_ulid') required String missionUlid,
  }) = _PRFMissionQuestionDTO;

  factory PRFMissionQuestionDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionQuestionDTOFromJson(json);
}
