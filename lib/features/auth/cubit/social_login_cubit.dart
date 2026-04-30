import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/_index.dart';
import 'package:logger/logger.dart';

part 'social_login_state.dart';
part 'social_login_cubit.freezed.dart';

class SocialLoginCubit extends Cubit<SocialLoginState> {
  SocialLoginCubit({
    required HiveService hiveService,
    required AuthService authService,
  }) : super(const SocialLoginState.initial()) {
    _hiveService = hiveService;
    _authService = authService;
  }

  late HiveService _hiveService;
  late AuthService _authService;

  Future<void> login({required SocialAuthDTO socialAuthDTO}) async {
    emit(const SocialLoginState.loading());
    try {
      final token = await _authService.socialLogin(
        socialAuthDTO: socialAuthDTO,
      );

      _hiveService.auth.persistToken(token);

      final user = await _authService.getUser();

      _hiveService.auth.persistProfile(user);

      emit(const SocialLoginState.loaded());
    } on Failure catch (e) {
      emit(SocialLoginState.error(e.message));
    } catch (e, stackTrace) {
      Logger().e(
        'Unexpected error during social login',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        SocialLoginState.error('Login with ${socialAuthDTO.provider} failed'),
      );
    }
  }
}
