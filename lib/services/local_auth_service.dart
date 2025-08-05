import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication localAuth = LocalAuthentication();

  Future<(bool, String?)> authenticateLocally() async {
    try {
      final result = await localAuth.authenticate(
        localizedReason: 'We need to protect your giving history.',
        options: const AuthenticationOptions(useErrorDialogs: false),
      );

      return (result, null);
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        return (
          false,
          'Biometric authentication is not available on this device.',
        );
      } else if (e.code == auth_error.notEnrolled) {
        return (
          false,
          'Biometric authentication is not enrolled on this device.',
        );
      } else {
        return (false, e.message);
      }
    }
  }
}
