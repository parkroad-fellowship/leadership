import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/services/api/requisition_item_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_item_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_detail_cubit.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_item_detail_cubit.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_item_resource_cubit.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_resource_cubit.dart';

class RequisitionsModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<RequisitionResourceCubit>(
        create: (context) => RequisitionResourceCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
          hiveDbService: getIt<RequisitionHiveDbService>(),
        ),
      ),
      BlocProvider<RequisitionItemResourceCubit>(
        create: (context) => RequisitionItemResourceCubit(
          requisitionItemService: getIt<RequisitionItemService>(),
          hiveDbService: getIt<RequisitionItemHiveDbService>(),
        ),
      ),
      BlocProvider<RequisitionDetailCubit>(
        create: (context) => RequisitionDetailCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveDbService: getIt<RequisitionHiveDbService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<RequisitionItemDetailCubit>(
        create: (context) => RequisitionItemDetailCubit(
          requisitionItemService: getIt<RequisitionItemService>(),
          hiveDbService: getIt<RequisitionItemHiveDbService>(),
        ),
      ),
    ];
  }
}
