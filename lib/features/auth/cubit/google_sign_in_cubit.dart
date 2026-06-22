import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/services/firebase_service.dart';

part 'google_sign_in_cubit.freezed.dart';
part 'google_sign_in_state.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  GoogleSignInCubit({required PRFFirebaseService firebaseService})
    : super(const GoogleSignInState.initial()) {
    _firebaseService = firebaseService;
  }

  late PRFFirebaseService _firebaseService;

  Future<void> signInwithGoogle() async {
    emit(const GoogleSignInState.loading());
    try {
      final result = await _firebaseService.signInWithGoogle();

      emit(GoogleSignInState.loaded(socialAuthDTO: result));
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      log(e.toString(), error: e);
      emit(const GoogleSignInState.error('Google Sign in failed'));
    }
  }
}
