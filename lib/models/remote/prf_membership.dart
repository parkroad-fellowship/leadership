import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_spiritual_year.dart';

part 'prf_membership.freezed.dart';
part 'prf_membership.g.dart';

@freezed
abstract class PRFMembership with _$PRFMembership {
  factory PRFMembership(
    String ulid,
    int type,
    int amount, {
    required bool approved,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'spiritual_year') PRFSpiritualYear? spiritualYear,
  }) = _PRFMembership;

  factory PRFMembership.fromJson(Map<String, dynamic> json) =>
      _$PRFMembershipFromJson(json);
}
