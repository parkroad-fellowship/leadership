part of 'upload_media_cubit.dart';

@freezed
abstract class UploadMediaState with _$UploadMediaState {
  const factory UploadMediaState.initial() = _Initial;
  const factory UploadMediaState.loading() = _Loading;
  const factory UploadMediaState.loaded() = _Loaded;
  const factory UploadMediaState.error(String message) = _Error;
}
