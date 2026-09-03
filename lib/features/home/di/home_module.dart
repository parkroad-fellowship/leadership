import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/services/api/expense_categories_service.dart';
import 'package:leadership/services/local_storage/hive/db/expense_category_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/services/media_service.dart';
import 'package:leadership/shared/expenses/cubit/expense_categories_resource_cubit.dart';
import 'package:leadership/shared/media_upload/cubit/select_media_cubit.dart';
import 'package:leadership/shared/media_upload/cubit/upload_media_cubit.dart';
import 'package:leadership/shared/theme/cubit/theme_cubit.dart';

class HomeModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<ThemeCubit>(
        create: (context) => ThemeCubit(hiveService: getIt<HiveService>()),
      ),
      BlocProvider<ExpenseCategoriesResourceCubit>(
        create: (context) => ExpenseCategoriesResourceCubit(
          expenseCategoriesService: getIt<ExpenseCategoriesService>(),
          hiveDbService: getIt<ExpenseCategoryHiveDbService>(),
        ),
      ),
      BlocProvider<SelectMediaCubit>(
        create: (context) => SelectMediaCubit(
          mediaService: getIt<MediaService>(),
        ),
      ),
      BlocProvider<UploadMediaCubit>(
        create: (context) => UploadMediaCubit(
          mediaService: getIt<MediaService>(),
        ),
      ),
    ];
  }
}
