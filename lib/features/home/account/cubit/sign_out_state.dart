part of 'sign_out_cubit.dart';

@freezed
abstract class SignOutState with _$SignOutState {
  const factory SignOutState.initial() = _Initial;
  const factory SignOutState.loading() = _Loading;
  const factory SignOutState.loaded() = _Loaded;
}
