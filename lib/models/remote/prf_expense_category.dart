import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_expense_category.freezed.dart';
part 'prf_expense_category.g.dart';

@freezed
abstract class PRFExpenseCategory with _$PRFExpenseCategory {
  factory PRFExpenseCategory(
    String ulid,
    String name,
    String description,
    @JsonKey(name: 'is_active') String isActive,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String updatedAt,
  ) = _PRFExpenseCategory;

  factory PRFExpenseCategory.fromJson(Map<String, dynamic> json) =>
      _$PRFExpenseCategoryFromJson(json);
}

@freezed
abstract class PRFExpenseCategoryResponse with _$PRFExpenseCategoryResponse {
  factory PRFExpenseCategoryResponse(List<PRFExpenseCategory> data) =
      _PRFExpenseCategoryResponse;

  factory PRFExpenseCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFExpenseCategoryResponseFromJson(json);
}
