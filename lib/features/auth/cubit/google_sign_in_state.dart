part of 'google_sign_in_cubit.dart';

@freezed
abstract class GoogleSignInState with _$GoogleSignInState {
  const factory GoogleSignInState.initial() = _Initial;
  const factory GoogleSignInState.loading() = _Loading;
  const factory GoogleSignInState.loaded({
    required SocialAuthDTO socialAuthDTO,
  }) = _Loaded;
  const factory GoogleSignInState.error(String message) = _Error;
}
