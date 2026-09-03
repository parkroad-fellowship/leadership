import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/members/cubit/member_resource_cubit.dart';
import 'package:leadership/services/api/member_service.dart';
import 'package:leadership/services/local_storage/hive/db/member_hive_db_service.dart';

class MembersModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<MemberResourceCubit>(
        create: (context) => MemberResourceCubit(
          memberService: getIt<MemberService>(),
          hiveDbService: getIt<MemberHiveDbService>(),
        ),
      ),
    ];
  }
}
