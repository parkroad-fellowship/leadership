import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class ExpenseCategoryHiveDbService
    extends BaseHiveDbService<PRFExpenseCategory> {
  @override
  String get boxName => 'prf_expense_categories';

  @override
  String getKey(PRFExpenseCategory entity) => entity.ulid;

  @override
  PRFExpenseCategory fromJson(Map<String, dynamic> json) =>
      PRFExpenseCategory.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFExpenseCategory entity) => entity.toJson();
}
