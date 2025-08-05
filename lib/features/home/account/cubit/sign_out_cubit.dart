import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'sign_out_state.dart';
part 'sign_out_cubit.freezed.dart';

class SignOutCubit extends Cubit<SignOutState> {
  SignOutCubit({
    required HiveService hiveService,
  }) : super(const SignOutState.initial()) {
    _hiveService = hiveService;
  }

  late HiveService _hiveService;

  Future<void> signOut() async {
    emit(const SignOutState.loading());

    try {
      _hiveService.clearPrefs();
      emit(const SignOutState.loaded());
    } catch (e) {
      emit(const SignOutState.loaded());
    }
  }
}
