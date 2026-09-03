import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/churches/cubit/church_resource_cubit.dart';
import 'package:leadership/services/api/church_service.dart';
import 'package:leadership/services/local_storage/hive/db/church_hive_db_service.dart';

class ChurchesModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<ChurchResourceCubit>(
        create: (context) => ChurchResourceCubit(
          churchService: getIt<ChurchService>(),
          hiveDbService: getIt<ChurchHiveDbService>(),
        ),
      ),
    ];
  }
}
