part of 'get_expense_categories_cubit.dart';

@freezed
abstract class GetExpenseCategoriesState with _$GetExpenseCategoriesState {
  const factory GetExpenseCategoriesState.initial() = _Initial;
  const factory GetExpenseCategoriesState.loading() = _Loading;
  const factory GetExpenseCategoriesState.loaded({
    required List<PRFExpenseCategory> expenseCategories,
  }) = _Loaded;
  const factory GetExpenseCategoriesState.error({required String message}) =
      _Error;
}
