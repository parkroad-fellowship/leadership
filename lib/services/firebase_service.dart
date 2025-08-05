import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/remote_config.dart';
import 'package:leadership/utils/misc.dart';
import 'package:logger/logger.dart';

abstract class FirebaseService {
  Future<SocialAuthDTO> signInWithGoogle();
  Future<void> initRemoteConfig();
  RemoteConfig getReviewConfig();
  Future<bool> canShowAuth();
  Future<String> retrieveFCMToken();
}

class FirebaseServiceImpl implements FirebaseService {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
    final config = remoteConfig.getValue('prf_missions_in_review_v2');

    return RemoteConfig.fromJson(
      json.decode(config.asString()) as Map<String, dynamic>,
    );
  }

  @override
  Future<bool> canShowAuth() async {
    final reviewConfig = getReviewConfig();
    Logger().i(reviewConfig);

    final currentVersion = Misc.getFullAppVersion();
    final currentPlatform = await _getCurrentPlatform();

    // Check if current platform and version is in review
    return reviewConfig.reviewConfigs.any(
      (config) =>
          config.isInReview &&
          config.appVersion == currentVersion &&
          (config.appStore == currentPlatform),
    );
  }

  Future<String> _getCurrentPlatform() async {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      // Check if this is a Huawei device without Google Play Services
      return await _isHuaweiDevice() ? 'huawei' : 'android';
    }
    return 'unknown';
  }

  Future<bool> _isHuaweiDevice() async {
    try {
      if (Platform.isAndroid) {
        return _checkHuaweiManufacturer();
      }
      return false;
    } catch (e) {
      Logger().e('Error checking Huawei device: $e');
      return false;
    }
  }

  Future<bool> _checkHuaweiManufacturer() async {
    try {
      // This is a synchronous check that should work in most cases
      // You can also make this async if needed
      final androidInfo = _deviceInfo.androidInfo;

      // Check common Huawei identifiers
      return await androidInfo
          .then((info) {
            final manufacturer = info.manufacturer.toLowerCase();
            final brand = info.brand.toLowerCase();

            return manufacturer.contains('huawei') ||
                manufacturer.contains('honor') ||
                brand.contains('huawei') ||
                brand.contains('honor');
          })
          .catchError((Object e) {
            Logger().e('Error getting Android info: $e');
            return false;
          });
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> retrieveFCMToken() async {
    try {
      final platform = await _getCurrentPlatform();
      Logger().i('Platform: $platform');

      if (platform == 'ios') {
        final settings = await _firebaseMessaging.requestPermission();
        Logger().i(
          'Notification permission status: ${settings.authorizationStatus}',
        );
        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          throw Exception('Notification permissions not granted');
        }

        // Retry APNS token up to 3 times with delay
        String? apnsToken;
        for (var i = 0; i < 3; i++) {
          apnsToken = await _firebaseMessaging.getAPNSToken();
          Logger().d('APNS Token (attempt ${i + 1}): $apnsToken');
          if (apnsToken != null) break;
          await Future<dynamic>.delayed(const Duration(seconds: 2));
        }
        if (apnsToken == null) {
          throw Exception('APNS token not set yet. Try again later.');
        }
      }

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        Logger().i('FCM Token: $token');
        return token;
      } else {
        throw Exception('Failed to retrieve FCM token');
      }
    } catch (error) {
      Logger().e('Error retrieving FCM token: $error');
      throw Failure(message: error.toString());
    }
  }
}
