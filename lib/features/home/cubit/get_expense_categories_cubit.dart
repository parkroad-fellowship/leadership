import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/services/api/expense_categories_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'get_expense_categories_state.dart';
part 'get_expense_categories_cubit.freezed.dart';

class GetExpenseCategoriesCubit extends Cubit<GetExpenseCategoriesState> {
  GetExpenseCategoriesCubit({
    required ExpenseCategoriesService expenseCategoriesService,
    required HiveService hiveService,
  }) : super(const GetExpenseCategoriesState.initial()) {
    _expenseCategoriesService = expenseCategoriesService;
    _hiveService = hiveService;
  }

  late ExpenseCategoriesService _expenseCategoriesService;
  late HiveService _hiveService;

  Future<void> getExpenseCategories() async {
    emit(const GetExpenseCategoriesState.loading());
    try {
      final localExpenseCategories = _hiveService.data
          .retrieveExpenseCategories();
      if (localExpenseCategories.isNotEmpty) {
        emit(
          GetExpenseCategoriesState.loaded(
            expenseCategories: localExpenseCategories,
          ),
        );
        return;
      }

      final expenseCategories = await _expenseCategoriesService.list(
        limit: 100,
      );
      _hiveService.data.expenses.persistExpenseCategories(
        PRFExpenseCategoryResponse(expenseCategories),
      );
      emit(
        GetExpenseCategoriesState.loaded(expenseCategories: expenseCategories),
      );
    } on Failure catch (e) {
      emit(GetExpenseCategoriesState.error(message: e.message));
    } catch (e) {
      emit(GetExpenseCategoriesState.error(message: e.toString()));
    }
  }
}
