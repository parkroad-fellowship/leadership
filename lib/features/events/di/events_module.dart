import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/events/cubit/event_resource_cubit.dart';
import 'package:leadership/features/events/desk_activity_details/cubit/payment_instruction_resource_cubit.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/services/api/payment_instruction_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/db/event_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/payment_instruction_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

class EventsModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<EventResourceCubit>(
        create: (context) => EventResourceCubit(
          eventService: getIt<EventService>(),
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
          hiveDbService: getIt<EventHiveDbService>(),
        ),
      ),
      BlocProvider<PaymentInstructionResourceCubit>(
        create: (context) => PaymentInstructionResourceCubit(
          paymentInstructionService: getIt<PaymentInstructionService>(),
          hiveDbService: getIt<PaymentInstructionHiveDbService>(),
        ),
      ),
    ];
  }
}
