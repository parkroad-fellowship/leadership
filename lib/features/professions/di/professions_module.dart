import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/professions/cubit/profession_resource_cubit.dart';
import 'package:leadership/services/api/profession_service.dart';
import 'package:leadership/services/local_storage/hive/db/profession_hive_db_service.dart';

class ProfessionsModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<ProfessionResourceCubit>(
        create: (context) => ProfessionResourceCubit(
          professionService: getIt<ProfessionService>(),
          hiveDbService: getIt<ProfessionHiveDbService>(),
        ),
      ),
    ];
  }
}
