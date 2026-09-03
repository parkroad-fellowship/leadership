import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/auth/cubit/google_sign_in_cubit.dart';
import 'package:leadership/features/auth/cubit/sign_in_cubit.dart';
import 'package:leadership/features/auth/cubit/social_login_cubit.dart';
import 'package:leadership/services/api/auth_service.dart';
import 'package:leadership/services/errors/unified_error_reporting_service.dart';
import 'package:leadership/services/firebase_messaging_service.dart';
import 'package:leadership/services/firebase_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/services/socket_service.dart';

class AuthModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<SigninCubit>(
        create: (context) => SigninCubit(
          authService: getIt<AuthService>(),
          hiveService: getIt<HiveService>(),
          socketService: getIt<SocketService>(),
          firebaseMessagingService: getIt<FirebaseMessagingService>(),
        ),
      ),
      BlocProvider<SocialLoginCubit>(
        create: (context) => SocialLoginCubit(
          hiveService: getIt<HiveService>(),
          authService: getIt<AuthService>(),
        ),
      ),
      BlocProvider<GoogleSignInCubit>(
        create: (context) => GoogleSignInCubit(
          firebaseService: getIt<PRFFirebaseService>(),
          errorReportingService: getIt<UnifiedErrorReportingService>(),
        ),
      ),
    ];
  }
}
