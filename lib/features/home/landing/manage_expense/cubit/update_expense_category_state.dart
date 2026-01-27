part of 'update_expense_category_cubit.dart';

@freezed
abstract class UpdateExpenseCategoryState with _$UpdateExpenseCategoryState {
  const factory UpdateExpenseCategoryState.initial() = _Initial;
  const factory UpdateExpenseCategoryState.loading() = _Loading;
  const factory UpdateExpenseCategoryState.loaded({
    required PRFExpenseCategory category,
  }) = _Loaded;
  const factory UpdateExpenseCategoryState.error(String message) = _Error;
}
