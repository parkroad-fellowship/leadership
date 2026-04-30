import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class ExpenseCategoriesService extends BaseAPIService<PRFExpenseCategory> {
  @override
  String get endpoint => '/expense-categories';

  @override
  PRFExpenseCategory createFromJson(Map<String, dynamic> json) {
    return PRFExpenseCategory.fromJson(json);
  }

  @override
  List<PRFExpenseCategory> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    return PRFExpenseCategoryResponse.fromJson(response).data;
  }
}
