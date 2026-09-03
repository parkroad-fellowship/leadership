import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/services/api/accounting_event_service.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';
import 'package:leadership/services/api/refund_service.dart';
import 'package:leadership/services/local_storage/hive/db/allocation_entry_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/refund_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/services/media_service.dart';
import 'package:leadership/shared/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/shared/expenses/cubit/refund_resource_cubit.dart';
import 'package:leadership/shared/expenses/cubit/send_financial_report_cubit.dart';

class ExpensesModule {
  static List<BlocProvider> registerCubits(GetIt getIt) {
    return <BlocProvider>[
      BlocProvider<AllocationEntryResourceCubit>(
        create: (context) => AllocationEntryResourceCubit(
          allocationEntryService: getIt<AllocationEntryService>(),
          hiveService: getIt<HiveService>(),
          mediaService: getIt<MediaService>(),
          hiveDbService: getIt<AllocationEntryHiveDbService>(),
        ),
      ),
      BlocProvider<RefundResourceCubit>(
        create: (context) => RefundResourceCubit(
          refundService: getIt<RefundService>(),
          hiveDbService: getIt<RefundHiveDbService>(),
        ),
      ),
      BlocProvider<SendFinancialReportCubit>(
        create: (context) => SendFinancialReportCubit(
          accountingEventService: getIt<AccountingEventService>(),
        ),
      ),
    ];
  }
}
