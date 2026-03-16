import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_soul_decision_type.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_class_group.dart';

part 'prf_soul.freezed.dart';
part 'prf_soul.g.dart';

@freezed
abstract class PRFSoul with _$PRFSoul {
  factory PRFSoul(
    String ulid,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'decision_type') PRFSoulDecisionType decisionType,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @JsonKey(name: 'admission_number') String? admissionNumber,
    String? notes,
    PRFMission? mission,
    @JsonKey(name: 'class_group') PRFClassGroup? classGroup,
  }) = _PRFSoul;

  factory PRFSoul.fromJson(Map<String, dynamic> json) =>
      _$PRFSoulFromJson(json);
}

@freezed
abstract class PRFSoulResponse with _$PRFSoulResponse {
  const factory PRFSoulResponse({required List<PRFSoul> data}) =
      _PRFSoulResponse;

  factory PRFSoulResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFSoulResponseFromJson(json);
}
