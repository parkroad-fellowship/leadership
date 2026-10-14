import 'package:bloc/bloc.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/services/api/accounting_event_service.dart';

typedef AccountingEventState = ({
  PRFAccountingEvent? event,
  bool loading,
  String? error,
});

/// Loads one accounting event (with its refunds) for the expenses screen,
/// so expense rows no longer embed the parent event's refunds on every row.
class AccountingEventCubit extends Cubit<AccountingEventState> {
  AccountingEventCubit(this._service)
    : super((event: null, loading: false, error: null));

  final AccountingEventService _service;
  String? _loadedUlid;

  Future<void> load(String ulid, {bool force = false}) async {
    if (!force && _loadedUlid == ulid && state.event != null) return;
    emit((event: state.event, loading: true, error: null));
    try {
      final event = await _service.get(
        ulid: ulid,
        includes: ['refunds', 'latestRefund'],
      );
      _loadedUlid = ulid;
      if (!isClosed) emit((event: event, loading: false, error: null));
    } on Failure catch (e) {
      if (!isClosed) {
        emit((event: state.event, loading: false, error: e.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit((event: state.event, loading: false, error: e.toString()));
      }
    }
  }
}
