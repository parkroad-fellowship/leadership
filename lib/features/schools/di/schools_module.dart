import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/schools/cubit/school_cubit.dart';
import 'package:leadership/services/api/contact_type_service.dart';
import 'package:leadership/services/api/school_contact_service.dart';
import 'package:leadership/services/api/school_service.dart';
import 'package:leadership/services/local_storage/hive/db/contact_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/contact_type_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/school_hive_db_service.dart';

class SchoolsModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<SchoolCubit>(
        create: (context) => SchoolCubit(
          schoolService: getIt<SchoolService>(),
          hiveDbService: getIt<SchoolHiveDbService>(),
        ),
      ),
      BlocProvider<ContactTypeCubit>(
        create: (context) => ContactTypeCubit(
          contactTypeService: getIt<ContactTypeService>(),
          hiveDbService: getIt<ContactTypeHiveDbService>(),
        ),
      ),
      BlocProvider<ContactCubit>(
        create: (context) => ContactCubit(
          schoolContactService: getIt<SchoolContactService>(),
          hiveDbService: getIt<ContactHiveDbService>(),
        ),
      ),
    ];
  }
}
