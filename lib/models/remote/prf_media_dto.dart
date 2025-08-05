import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_media_model.dart';

part 'prf_media_dto.freezed.dart';
part 'prf_media_dto.g.dart';

@freezed
abstract class PRFMediaDTO with _$PRFMediaDTO {
  const factory PRFMediaDTO({
    required PRFMediaModel model,
    required String modelUlid,
    required String path,
    required String name,
  }) = _PRFMediaDTO;

  factory PRFMediaDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMediaDTOFromJson(json);
}
