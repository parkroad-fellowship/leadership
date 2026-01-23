import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/services/api/expense_categories_service.dart';

part 'get_expense_categories_cubit.freezed.dart';
part 'get_expense_categories_state.dart';

class ExpenseCategoriesCubit extends Cubit<ExpenseCategoriesState> {
  ExpenseCategoriesCubit({
    required ExpenseCategoriesService expenseCategoriesService,
  }) : super(const ExpenseCategoriesState.initial()) {
    _expenseCategoriesService = expenseCategoriesService;
  }
  late ExpenseCategoriesService _expenseCategoriesService;

  Future<void> getExpenseCategories() async {
    emit(const ExpenseCategoriesState.loading());
    try {
      final categories = await _expenseCategoriesService.list();
      emit(ExpenseCategoriesState.loaded(categories));
    } catch (e) {
      emit(ExpenseCategoriesState.error(e.toString()));
    }
  }
}
