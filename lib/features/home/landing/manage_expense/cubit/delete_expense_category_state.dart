part of 'delete_expense_category_cubit.dart';

@freezed
abstract class DeleteExpenseCategoryState with _$DeleteExpenseCategoryState {
  const factory DeleteExpenseCategoryState.initial() = _Initial;
  const factory DeleteExpenseCategoryState.loading() = _Loading;
  const factory DeleteExpenseCategoryState.loaded() = _Loaded;
  const factory DeleteExpenseCategoryState.error(String message) = _Error;
}
