import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/gifts/cubit/gift_resource_cubit.dart';
import 'package:leadership/services/api/gift_service.dart';
import 'package:leadership/services/local_storage/hive/db/gift_hive_db_service.dart';

class GiftsModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<GiftResourceCubit>(
        create: (context) => GiftResourceCubit(
          giftService: getIt<GiftService>(),
          hiveDbService: getIt<GiftHiveDbService>(),
        ),
      ),
    ];
  }
}
