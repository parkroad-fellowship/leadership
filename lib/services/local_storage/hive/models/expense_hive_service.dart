import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/services/local_storage/hive/_base_hive_service.dart';
import 'package:leadership/utils/_index.dart';

class ExpenseHiveService extends BaseHiveService {
  @override
  String get boxName => PRFLeadershipConfig.instance!.values.hiveBox;

  // Expense Categories
  void persistExpenseCategories(PRFExpenseCategoryResponse expenseCategories) {
    put('expenseCategories', expenseCategories);
  }

  List<PRFExpenseCategory> retrieveExpenseCategories() {
    final expenseCategories = get<PRFExpenseCategoryResponse>(
      'expenseCategories',
    );
    if (expenseCategories == null) return [];
    return expenseCategories.data;
  }

  void clearExpenseCategories() {
    delete('expenseCategories');
  }
}
