import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/home/account/cubit/change_profile_picture_cubit.dart';
import 'package:leadership/features/home/account/cubit/sign_out_cubit.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/services/media_service.dart';

class AccountModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<ChangeProfilePictureCubit>(
        create: (context) => ChangeProfilePictureCubit(
          mediaService: getIt<MediaService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<SignOutCubit>(
        create: (context) => SignOutCubit(
          hiveService: getIt<HiveService>(),
        ),
      ),
    ];
  }
}
