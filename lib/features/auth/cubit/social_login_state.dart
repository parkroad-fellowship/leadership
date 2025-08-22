part of 'social_login_cubit.dart';

@freezed
abstract class SocialLoginState with _$SocialLoginState {
  const factory SocialLoginState.initial() = _Initial;
  const factory SocialLoginState.loading() = _Loading;
  const factory SocialLoginState.loaded() = _Loaded;
  const factory SocialLoginState.error(String error) = _Error;
}
