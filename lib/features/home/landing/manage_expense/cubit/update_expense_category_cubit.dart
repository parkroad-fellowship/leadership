import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';

import 'package:leadership/services/api/expense_categories_service.dart';

part 'update_expense_category_cubit.freezed.dart';
part 'update_expense_category_state.dart';

class UpdateExpenseCategoryCubit extends Cubit<UpdateExpenseCategoryState> {
  UpdateExpenseCategoryCubit({
    required ExpenseCategoriesService expenseCategoriesService,
  }) : super(const UpdateExpenseCategoryState.initial()) {
    _expenseCategoriesService = expenseCategoriesService;
  }

  late ExpenseCategoriesService _expenseCategoriesService;

  Future<void> updateExpenseCategory({
    required String ulid,
    required String name,

    required String description,
  }) async {
    emit(const UpdateExpenseCategoryState.loading());
    try {
      final expenseCategory = await _expenseCategoriesService.update(
        id: ulid,
        data: {
          'name': name,

          'description': description,
        },
      );
      emit(UpdateExpenseCategoryState.loaded(category: expenseCategory));
    } on Failure catch (e) {
      emit(UpdateExpenseCategoryState.error(e.message));
    } catch (e) {
      emit(UpdateExpenseCategoryState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const UpdateExpenseCategoryState.initial());
  }
}
