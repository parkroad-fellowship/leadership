import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/services/api/expense_categories_service.dart';
import 'package:leadership/services/local_storage/hive/db/expense_category_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class ExpenseCategoriesResourceCubit extends ResourceCubit<PRFExpenseCategory> {
  ExpenseCategoriesResourceCubit({
    required ExpenseCategoriesService expenseCategoriesService,
    required ExpenseCategoryHiveDbService hiveDbService,
  }) : super(service: expenseCategoriesService, dbService: hiveDbService);

  @override
  Future<List<PRFExpenseCategory>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }
}
