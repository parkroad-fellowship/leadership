import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_media.freezed.dart';
part 'prf_media.g.dart';

@freezed
abstract class PRFMedia with _$PRFMedia {
  factory PRFMedia(
    String uuid,
    @JsonKey(name: 'public_temporary_url') String temporaryURL,
    int size,
    @JsonKey(name: 'human_readable_size') String humanReadableSize,
    @JsonKey(name: 'mime_type') String mimeType,
    String name,
    @JsonKey(name: 'file_name') String fileName,
    @JsonKey(name: 'collection_name') String collectionName,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFMedia;

  factory PRFMedia.fromJson(Map<String, dynamic> json) =>
      _$PRFMediaFromJson(json);
}

@freezed
abstract class PRFMediaResponse with _$PRFMediaResponse {
  factory PRFMediaResponse({required List<PRFMedia> data}) = _PRFMediaResponse;

  factory PRFMediaResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFMediaResponseFromJson(json);
}
