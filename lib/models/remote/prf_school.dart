import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/models/remote/prf_contact.dart';

part 'prf_school.freezed.dart';
part 'prf_school.g.dart';

@freezed
abstract class PRFSchool with _$PRFSchool {
  factory PRFSchool(
    String ulid,
    String name,
    @JsonKey(name: 'total_students') int totalStudents,
    @JsonKey(name: 'institution_type') PRFInstitutionType institutionType,
    String address,
    double latitude,
    double longitude,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @Default('N/A') String description,
    @Default('N/A') String directions,
    @Default('N/A') String distance,
    @Default('N/A') @JsonKey(name: 'static_duration') String staticDuration,
    @Default([]) @JsonKey(name: 'school_contacts') List<PRFContact> contacts,
  }) = _PRFSchool;

  factory PRFSchool.fromJson(Map<String, dynamic> json) =>
      _$PRFSchoolFromJson(json);
}

@freezed
abstract class PRFSchoolResponse with _$PRFSchoolResponse {
  factory PRFSchoolResponse(
    List<PRFSchool> data,
  ) = _PRFSchoolResponse;
  factory PRFSchoolResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFSchoolResponseFromJson(json);
}
