import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_school_term.freezed.dart';
part 'prf_school_term.g.dart';

@freezed
abstract class PRFSchoolTerm with _$PRFSchoolTerm {
  factory PRFSchoolTerm(
    String ulid,
    String name,
    int year,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFSchoolTerm;

  factory PRFSchoolTerm.fromJson(Map<String, dynamic> json) =>
      _$PRFSchoolTermFromJson(json);
}
