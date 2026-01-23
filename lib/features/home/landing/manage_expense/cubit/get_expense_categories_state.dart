part of 'get_expense_categories_cubit.dart';

@freezed
class ExpenseCategoriesState with _$ExpenseCategoriesState {
  const factory ExpenseCategoriesState.initial() = _Initial;

  const factory ExpenseCategoriesState.loading() = _Loading;

  const factory ExpenseCategoriesState.loaded(
    List<PRFExpenseCategory> categories,
  ) = _Loaded;

  const factory ExpenseCategoriesState.empty() = _Empty;

  const factory ExpenseCategoriesState.error(String message) = _Error;
}
