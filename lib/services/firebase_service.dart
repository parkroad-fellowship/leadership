import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leadership/enums/prf_environment.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/remote_config.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';

abstract class PRFFirebaseService {
  Future<SocialAuthDTO> signInWithGoogle();
  Future<void> initRemoteConfig();
  RemoteConfig getReviewConfig();
  Future<bool> canShowAuth();
}

class FirebaseServiceImpl implements PRFFirebaseService {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleSignInInitialization;

  static const List<String> _googleAuthScopes = [
    'profile',
    'email',
    'openid',
  ];

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= _googleSignIn.initialize();
  }

  @override
  Future<SocialAuthDTO> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      // Clear any existing session
      await _auth.signOut();
      await _googleSignIn.signOut();

      // Web requires a different authentication flow
      if (kIsWeb) {
        return _signInWithGoogleWeb();
      } else {
        return _signInWithGoogleMobile();
      }
    } catch (e) {
      log(e.toString(), error: e);
      rethrow;
    }
  }

  Future<SocialAuthDTO> _signInWithGoogleMobile() async {
    final googleSignInAccount = await _googleSignIn.authenticate(
      scopeHint: _googleAuthScopes,
    );
    final googleSignInAuthentication = googleSignInAccount.authentication;
    final googleClientAuthorization =
        await googleSignInAccount.authorizationClient.authorizationForScopes(
          _googleAuthScopes,
        ) ??
        await googleSignInAccount.authorizationClient.authorizeScopes(
          _googleAuthScopes,
        );

    if (googleSignInAuthentication.idToken == null) {
      throw Exception('Google sign-in did not return an ID token');
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleClientAuthorization.accessToken,
    );

    final authResult = await _auth.signInWithCredential(credential);

    final user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous, 'User must not be anonymous');

      return SocialAuthDTO(
        provider: 'google',
        accessToken: googleClientAuthorization.accessToken,
      );
    } else {
      throw Exception('An error occurred');
    }
  }

  Future<SocialAuthDTO> _signInWithGoogleWeb() async {
    // On web, use Firebase's signInWithPopup with GoogleAuthProvider
    final googleProvider = GoogleAuthProvider();

    try {
      final userCredential = await _auth.signInWithPopup(googleProvider);

      final user = userCredential.user;

      if (user != null) {
        assert(!user.isAnonymous, 'User must not be anonymous');

        // Extract access token from the credential
        final credential = userCredential.credential;
        var accessToken = '';

        if (credential is OAuthCredential) {
          accessToken = credential.accessToken ?? '';
        }

        return SocialAuthDTO(
          provider: 'google',
          accessToken: accessToken,
        );
      } else {
        throw Exception('An error occurred');
      }
    } catch (e) {
      log('Web sign-in error: $e', error: e);
      rethrow;
    }
  }

  @override
  Future<void> initRemoteConfig() async {
    try {
      await remoteConfig.fetchAndActivate();
    } on FirebaseException catch (error, stackTrace) {
      final message = error.message ?? '';
      final isIosInstallationsKeychainIssue =
          defaultTargetPlatform == TargetPlatform.iOS &&
          (message.contains('SecItemAdd (-34018)') ||
              message.contains('Failed to get installations token'));

      if (isIosInstallationsKeychainIssue) {
        Logger().w(
          'Skipping Remote Config fetch due to iOS keychain access issue '
          '(SecItemAdd -34018).',
        );
        return;
      }

      log(
        'Remote Config init failed: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
              (config.appStore == currentPlatform.name),
        ) ||
        ([
          PRFEnvironment.staging,
          PRFEnvironment.development,
        ].contains(PRFLeadershipConfig.instance?.values.environment));
  }
}
