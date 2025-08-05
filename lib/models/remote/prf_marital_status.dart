import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_marital_status.freezed.dart';
part 'prf_marital_status.g.dart';

@freezed
abstract class PRFMaritalStatus with _$PRFMaritalStatus {
  factory PRFMaritalStatus(
    String ulid,
    String name,
    @JsonKey(name: 'is_active') int isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFMaritalStatus;

  factory PRFMaritalStatus.fromJson(Map<String, dynamic> json) =>
      _$PRFMaritalStatusFromJson(json);
}
