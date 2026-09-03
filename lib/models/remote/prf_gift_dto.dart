import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_gift_dto.freezed.dart';
part 'prf_gift_dto.g.dart';

@freezed
abstract class PRFGiftDTO with _$PRFGiftDTO {
  factory PRFGiftDTO({
    required String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus? isActive,
  }) = _PRFGiftDTO;

  factory PRFGiftDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFGiftDTOFromJson(json);
}
