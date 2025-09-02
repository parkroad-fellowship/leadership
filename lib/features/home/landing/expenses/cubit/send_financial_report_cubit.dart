import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/accounting_event_service.dart';

part 'send_financial_report_state.dart';
part 'send_financial_report_cubit.freezed.dart';

class SendFinancialReportCubit extends Cubit<SendFinancialReportState> {
  SendFinancialReportCubit({
    required AccountingEventService accountingEventService,
  }) : super(const SendFinancialReportState.initial()) {
    _accountingEventService = accountingEventService;
  }

  late AccountingEventService _accountingEventService;

  Future<void> sendReport({
    required String accountingEventUlid,
  }) async {
    emit(const SendFinancialReportState.loading());
    try {
      await _accountingEventService.sendReport(ulid: accountingEventUlid);
      emit(const SendFinancialReportState.loaded());
    } on Failure catch (f) {
      emit(SendFinancialReportState.error(f.message));
    } catch (e) {
      emit(SendFinancialReportState.error(e.toString()));
    }
  }
}
