part of 'add_expense_category_cubit.dart';

@freezed
abstract class AddExpenseCategoryState with _$AddExpenseCategoryState {
  const factory AddExpenseCategoryState.initial() = _Initial;
  const factory AddExpenseCategoryState.loading() = _Loading;
  const factory AddExpenseCategoryState.loaded(PRFExpenseCategory category) =
      _Loaded;
  const factory AddExpenseCategoryState.error(String message) = _Error;
}
