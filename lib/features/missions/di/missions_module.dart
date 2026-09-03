import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/missions/cubit/class_group_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/debrief_note_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_detail_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_ground_suggestion_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_offline_member_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_question_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_session_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_subscription_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_type_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/past_mission_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/school_term_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/soul_resource_cubit.dart';
import 'package:leadership/services/api/class_group_service.dart';
import 'package:leadership/services/api/debrief_note_service.dart';
import 'package:leadership/services/api/mission_ground_suggestion_service.dart';
import 'package:leadership/services/api/mission_offline_member_service.dart';
import 'package:leadership/services/api/mission_question_service.dart';
import 'package:leadership/services/api/mission_service.dart';
import 'package:leadership/services/api/mission_session_service.dart';
import 'package:leadership/services/api/mission_subscription_service.dart';
import 'package:leadership/services/api/mission_type_service.dart';
import 'package:leadership/services/api/school_service.dart';
import 'package:leadership/services/api/school_term_service.dart';
import 'package:leadership/services/api/soul_service.dart';
import 'package:leadership/services/local_storage/hive/db/class_group_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/debrief_note_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_ground_suggestion_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_offline_member_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_question_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_session_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_subscription_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_type_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/school_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/school_term_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/soul_hive_db_service.dart';

class MissionsModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<MissionResourceCubit>(
        create: (context) => MissionResourceCubit(
          missionService: getIt<MissionService>(),
          hiveDbService: getIt<MissionHiveDbService>(),
        ),
      ),
      BlocProvider<MissionDetailCubit>(
        create: (context) => MissionDetailCubit(
          missionService: getIt<MissionService>(),
          hiveDbService: getIt<MissionHiveDbService>(),
        ),
      ),
      BlocProvider<MissionQuestionResourceCubit>(
        create: (context) => MissionQuestionResourceCubit(
          missionQuestionService: getIt<MissionQuestionService>(),
          hiveDbService: getIt<MissionQuestionHiveDbService>(),
        ),
      ),
      BlocProvider<MissionSubscriptionResourceCubit>(
        create: (context) => MissionSubscriptionResourceCubit(
          missionSubscriptionService: getIt<MissionSubscriptionService>(),
          hiveDbService: getIt<MissionSubscriptionHiveDbService>(),
        ),
      ),
      BlocProvider<MissionOfflineMemberResourceCubit>(
        create: (context) => MissionOfflineMemberResourceCubit(
          missionOfflineMemberService: getIt<MissionOfflineMemberService>(),
          hiveDbService: getIt<MissionOfflineMemberHiveDbService>(),
        ),
      ),
      BlocProvider<MissionSessionResourceCubit>(
        create: (context) => MissionSessionResourceCubit(
          missionSessionService: getIt<MissionSessionService>(),
          hiveDbService: getIt<MissionSessionHiveDbService>(),
        ),
      ),
      BlocProvider<MissionTypeResourceCubit>(
        create: (context) => MissionTypeResourceCubit(
          missionTypeService: getIt<MissionTypeService>(),
          hiveDbService: getIt<MissionTypeHiveDbService>(),
        ),
      ),
      BlocProvider<SchoolTermResourceCubit>(
        create: (context) => SchoolTermResourceCubit(
          schoolTermService: getIt<SchoolTermService>(),
          hiveDbService: getIt<SchoolTermHiveDbService>(),
        ),
      ),
      BlocProvider<ClassGroupResourceCubit>(
        create: (context) => ClassGroupResourceCubit(
          classGroupService: getIt<ClassGroupService>(),
          hiveDbService: getIt<ClassGroupHiveDbService>(),
        ),
      ),
      BlocProvider<SoulResourceCubit>(
        create: (context) => SoulResourceCubit(
          missionSoulService: getIt<MissionSoulService>(),
          hiveDbService: getIt<SoulHiveDbService>(),
        ),
      ),
      BlocProvider<DebriefNoteResourceCubit>(
        create: (context) => DebriefNoteResourceCubit(
          missionDebriefNoteService: getIt<DebriefNoteService>(),
          hiveDbService: getIt<DebriefNoteHiveDbService>(),
        ),
      ),
      BlocProvider<MissionGroundSuggestionResourceCubit>(
        create: (context) => MissionGroundSuggestionResourceCubit(
          missionGroundSuggestionService:
              getIt<MissionGroundSuggestionService>(),
          hiveDbService: getIt<MissionGroundSuggestionHiveDbService>(),
        ),
      ),
      BlocProvider<PastMissionResourceCubit>(
        create: (context) => PastMissionResourceCubit(
          schoolService: getIt<SchoolService>(),
          hiveDbService: getIt<SchoolHiveDbService>(),
        ),
      ),
    ];
  }
}
