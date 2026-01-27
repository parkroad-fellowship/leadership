import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/expense_categories_service.dart';

part 'delete_expense_category_state.dart';
part 'delete_expense_category_cubit.freezed.dart';

class DeleteExpenseCategoryCubit extends Cubit<DeleteExpenseCategoryState> {
  DeleteExpenseCategoryCubit({
    required ExpenseCategoriesService expenseCategoriesService,
  }) : super(const DeleteExpenseCategoryState.initial()) {
    _expenseCategoriesService = expenseCategoriesService;
  }

  late ExpenseCategoriesService _expenseCategoriesService;

  Future<void> deleteExpenseCategory({required String ulid}) async {
    emit(const DeleteExpenseCategoryState.loading());

    try {
      await _expenseCategoriesService.delete(ulid: ulid);

      emit(const DeleteExpenseCategoryState.loaded());
    } on Failure catch (e) {
      emit(DeleteExpenseCategoryState.error(e.message));
    } catch (e) {
      emit(DeleteExpenseCategoryState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const DeleteExpenseCategoryState.initial());
  }
}
