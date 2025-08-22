import 'package:leadership/models/remote/prf_expense.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class ExpenseService extends BaseAPIService<PRFExpense> {
  @override
  String get endpoint => '/expenses';

  @override
  PRFExpense createFromJson(Map<String, dynamic> json) {
    return PRFExpense.fromJson(json);
  }

  @override
  List<PRFExpense> createListFromResponse(Map<String, dynamic> response) {
    throw UnimplementedError(
      'ExpenseService does not support list responses yet.',
    );
  }
}
