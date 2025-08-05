import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_group.dart';

part 'prf_group_member.freezed.dart';
part 'prf_group_member.g.dart';

@freezed
abstract class PRFGroupMember with _$PRFGroupMember {
  factory PRFGroupMember(
    String ulid,
    @JsonKey(name: 'start_date') String startDate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @JsonKey(name: 'end_date') String? endDate,
    PRFGroup? group,
  }) = _PRFGroupMember;

  factory PRFGroupMember.fromJson(Map<String, dynamic> json) =>
      _$PRFGroupMemberFromJson(json);
}
