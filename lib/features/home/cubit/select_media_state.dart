part of 'select_media_cubit.dart';

@freezed
class SelectMediaState with _$SelectMediaState {
  const factory SelectMediaState.initial() = _Initial;
  const factory SelectMediaState.loading() = _Loading;
  const factory SelectMediaState.loaded({required List<PRFMediaDTO> media}) =
      _Loaded;
  const factory SelectMediaState.empty() = _Empty;
  const factory SelectMediaState.error(String message) = _Error;
}
