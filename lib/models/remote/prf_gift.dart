import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_gift.freezed.dart';
part 'prf_gift.g.dart';

@freezed
abstract class PRFGift with _$PRFGift {
  factory PRFGift(
    String ulid,
    String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFGift;

  factory PRFGift.fromJson(Map<String, dynamic> json) =>
      _$PRFGiftFromJson(json);
}
