import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class AccountingEventService extends BaseAPIService<PRFAccountingEvent> {
  @override
  String get endpoint => '/accounting-events';

  @override
  PRFAccountingEvent createFromJson(Map<String, dynamic> json) {
    return PRFAccountingEvent.fromJson(json);
  }

  @override
  List<PRFAccountingEvent> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    throw UnimplementedError();
  }

  Future<bool> sendReport({
    required String ulid,
  }) async {
    try {
      await networkUtil.post(
        '$endpoint/$ulid/send-report',
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
