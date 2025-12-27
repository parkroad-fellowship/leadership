import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/remote_config.dart';
import 'package:leadership/utils/misc.dart';
import 'package:logger/logger.dart';

abstract class FirebaseService {
  Future<SocialAuthDTO> signInWithGoogle();
  Future<void> initRemoteConfig();
  RemoteConfig getReviewConfig();
  Future<bool> canShowAuth();
}

class FirebaseServiceImpl implements FirebaseService {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);

  @override
  Future<SocialAuthDTO> signInWithGoogle() async {
    try {
      // Clear any existing session
      await _auth.signOut();
      await _googleSignIn.signOut();

      final googleSignInAccount = await _googleSignIn.signIn();
      final googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );

      final authResult = await _auth.signInWithCredential(credential);

      final user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous, 'User must not be anonymous');

        return Future.value(
          SocialAuthDTO(
            provider: 'google',
            accessToken: googleSignInAuthentication?.accessToken ?? '',
          ),
        );
      } else {
        return throw Exception('An error occured');
      }
    } catch (e) {
      log(e.toString(), error: e);
      rethrow;
    }
  }

  @override
  Future<void> initRemoteConfig() async {
    await remoteConfig.fetchAndActivate();
  }

  @override
  RemoteConfig getReviewConfig() {
    final config = remoteConfig.getValue('prf_leadership_in_review');

    return RemoteConfig.fromJson(
      json.decode(config.asString()) as Map<String, dynamic>,
    );
  }

  @override
  Future<bool> canShowAuth() async {
    final reviewConfig = getReviewConfig();
    Logger().i(reviewConfig);

    final currentVersion = Misc.getFullAppVersion();
    final currentPlatform = await Misc.getCurrentPlatform();

    // Check if current platform and version is in review
    return reviewConfig.reviewConfigs.any(
      (config) =>
          config.isInReview &&
          config.appVersion == currentVersion &&
          (config.appStore == currentPlatform),
    );
  }
}
