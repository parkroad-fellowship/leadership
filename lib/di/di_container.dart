import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/di/modules/core_module.dart';
import 'package:leadership/di/modules/firebase_module.dart';
import 'package:leadership/di/modules/media_module.dart';
import 'package:leadership/features/auth/di/auth_module.dart';
import 'package:leadership/features/churches/di/churches_module.dart';
import 'package:leadership/features/departments/di/departments_module.dart';
import 'package:leadership/features/events/di/events_module.dart';
import 'package:leadership/features/gifts/di/gifts_module.dart';
import 'package:leadership/features/home/account/di/account_module.dart';
import 'package:leadership/features/home/di/home_module.dart';
import 'package:leadership/features/marital_statuses/di/marital_statuses_module.dart';
import 'package:leadership/features/members/di/members_module.dart';
import 'package:leadership/features/missions/di/missions_module.dart';
import 'package:leadership/features/professions/di/professions_module.dart';
import 'package:leadership/features/schools/di/schools_module.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/services/notification_service.dart';
import 'package:leadership/services/socket_service.dart';
import 'package:leadership/shared/expenses/di/expenses_module.dart';
import 'package:leadership/shared/requisitions/di/requisitions_module.dart';

final GetIt getIt = GetIt.instance;

class DIContainer {
  static void setup() {
    CoreModule.register(getIt);
    FirebaseModule.register(getIt);
    MediaModule.register(getIt);

    getIt
      ..registerSingleton<NotificationService>(NotificationServiceImpl())
      ..registerSingleton<SocketService>(SocketServiceImpl());
  }

  static Future<void> initializeDatabases() async {
    await getIt<HiveService>().initBoxes();
  }

  static List<BlocProvider> registerCubits() {
    final providers = <BlocProvider>[
      ...HomeModule.registerCubits(getIt),
      ...AccountModule.registerCubits(getIt),
      ...AuthModule.registerCubits(getIt),
      ...MissionsModule.registerCubits(getIt),
      ...SchoolsModule.registerCubits(getIt),
      ...EventsModule.registerCubits(getIt),
      ...MembersModule.registerCubits(getIt),
      ...ChurchesModule.registerCubits(getIt),
      ...DepartmentsModule.registerCubits(getIt),
      ...GiftsModule.registerCubits(getIt),
      ...ProfessionsModule.registerCubits(getIt),
      ...MaritalStatusesModule.registerCubits(getIt),
      ...ExpensesModule.registerCubits(getIt),
      ...RequisitionsModule.registerCubits(getIt),
    ];
    return providers;
  }
}
