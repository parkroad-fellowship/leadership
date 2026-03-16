import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_membership_entry_dto.freezed.dart';
part 'prf_membership_entry_dto.g.dart';

@freezed
abstract class PRFMembershipEntryDTO with _$PRFMembershipEntryDTO {
  factory PRFMembershipEntryDTO({
    @JsonKey(name: 'spiritual_year_ulid') required String spiritualYearUlid,
    required String type,
    @JsonKey(includeIfNull: false) bool? approved,
    @JsonKey(includeIfNull: false) double? amount,
  }) = _PRFMembershipEntryDTO;

  factory PRFMembershipEntryDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMembershipEntryDTOFromJson(json);
}
