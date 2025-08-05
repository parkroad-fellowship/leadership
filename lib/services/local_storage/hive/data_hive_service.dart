import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/services/local_storage/hive/_base_hive_service.dart';
import 'package:leadership/services/local_storage/hive/models/expense_hive_service.dart';
import 'package:leadership/utils/_index.dart';

class DataHiveService extends BaseHiveService {
  @override
  String get boxName => PRFLeadershipConfig.instance!.values.hiveBox;

  // Model-specific services
  late final ExpenseHiveService _expenses;

  // Initialize sub-services
  void initialize() {
    _expenses = ExpenseHiveService();
  }

  // Getters for sub-services
  ExpenseHiveService get expenses => _expenses;

  // Convenience methods that delegate to sub-services
  List<PRFExpenseCategory> retrieveExpenseCategories() =>
      _expenses.retrieveExpenseCategories();

  // Clear all data
  void clearDataCache() {
    _expenses.clear();
  }
}
