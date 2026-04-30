part of 'send_financial_report_cubit.dart';

@freezed
class SendFinancialReportState with _$SendFinancialReportState {
  const factory SendFinancialReportState.initial() = _Initial;
  const factory SendFinancialReportState.loading() = _Loading;
  const factory SendFinancialReportState.loaded() = _Loaded;
  const factory SendFinancialReportState.error(String error) = _Error;
}
