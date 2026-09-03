import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/marital_statuses/cubit/marital_status_resource_cubit.dart';
import 'package:leadership/services/api/marital_status_service.dart';
import 'package:leadership/services/local_storage/hive/db/marital_status_hive_db_service.dart';

class MaritalStatusesModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<MaritalStatusResourceCubit>(
        create: (context) => MaritalStatusResourceCubit(
          maritalStatusService: getIt<MaritalStatusService>(),
          hiveDbService: getIt<MaritalStatusHiveDbService>(),
        ),
      ),
    ];
  }
}
