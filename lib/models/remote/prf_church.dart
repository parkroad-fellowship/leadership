import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_church.freezed.dart';
part 'prf_church.g.dart';

@freezed
abstract class PRFChurch with _$PRFChurch {
  factory PRFChurch(
    String ulid,
    String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFChurch;

  factory PRFChurch.fromJson(Map<String, dynamic> json) =>
      _$PRFChurchFromJson(json);
}
