part of 'change_profile_picture_cubit.dart';

@freezed
abstract class ChangeProfilePictureState with _$ChangeProfilePictureState {
  const factory ChangeProfilePictureState.initial() = _Initial;
  const factory ChangeProfilePictureState.loading() = _Loading;
  const factory ChangeProfilePictureState.loaded() = _Loaded;
  const factory ChangeProfilePictureState.empty() = _Empty;
  const factory ChangeProfilePictureState.error(String message) = _Error;
}
