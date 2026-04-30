import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/socket_config.dart';
import 'package:leadership/services/_index.dart';
import 'package:logger/logger.dart';

part 'sign_in_state.dart';
part 'sign_in_cubit.freezed.dart';

class SigninCubit extends Cubit<SignInState> {
  SigninCubit({
    required AuthService authService,
    required HiveService hiveService,
    required SocketService socketService,
    required FirebaseMessagingService firebaseMessagingService,
  }) : super(const SignInState.initial()) {
    _authService = authService;
    _hiveService = hiveService;
    _socketService = socketService;
    _firebaseMessagingService = firebaseMessagingService;
  }
  late HiveService _hiveService;
  late AuthService _authService;
  late SocketService _socketService;
  late FirebaseMessagingService _firebaseMessagingService;

  Future<void> signIn({required String email, required String password}) async {
    emit(const SignInState.loading());
    try {
      final token = await _authService.signIn(
        signInDTO: SignInDTO(email: email, password: password),
      );

      _hiveService.auth.persistToken(token);

      final user = await _authService.getUser();

      _hiveService.auth.persistProfile(user);

      await _socketService.init(
        socketConfig: SocketConfig(
          privateChannels: _socketService.defaultConfig().privateChannels,
          presenceChannels: _socketService.defaultConfig().presenceChannels,
        ),
      );

      emit(const SignInState.loaded());
    } on Failure catch (e) {
      emit(SignInState.error(e.message));
    } catch (e, stackTrace) {
      Logger().e('SignInCubit signIn error: $e', stackTrace: stackTrace);
      emit(const SignInState.error('An unknown error occurred'));
    }

    final fcmToken = await _firebaseMessagingService.retrieveFCMToken();
    if (fcmToken.isNotEmpty) {
      await _authService.updateProfile(
        updateDTO: UserUpdateDTO(
          fcmTokens: [fcmToken],
        ),
      );
    }
  }
}
