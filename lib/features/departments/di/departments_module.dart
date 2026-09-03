import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/departments/cubit/department_resource_cubit.dart';
import 'package:leadership/services/api/department_service.dart';
import 'package:leadership/services/local_storage/hive/db/department_hive_db_service.dart';

class DepartmentsModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<DepartmentResourceCubit>(
        create: (context) => DepartmentResourceCubit(
          departmentService: getIt<DepartmentService>(),
          hiveDbService: getIt<DepartmentHiveDbService>(),
        ),
      ),
    ];
  }
}
