import 'package:leadership/models/remote/prf_mission_expense.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionExpensesService extends BaseAPIService<PRFMissionExpense> {
  @override
  String get endpoint => '/mission-expenses';

  @override
  PRFMissionExpense createFromJson(Map<String, dynamic> json) {
    return PRFMissionExpense.fromJson(json);
  }

  @override
  List<PRFMissionExpense> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    throw UnimplementedError(
      'MissionExpensesService does not support list responses yet.',
    );
  }
}
