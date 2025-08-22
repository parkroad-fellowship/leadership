import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_mission_expense.dart';
import 'package:leadership/services/api/mission_expenses_service.dart';

part 'get_mission_expense_state.dart';
part 'get_mission_expense_cubit.freezed.dart';

class GetMissionExpenseCubit extends Cubit<GetMissionExpenseState> {
  GetMissionExpenseCubit({
    required MissionExpensesService missionExpensesService,
  }) : super(const GetMissionExpenseState.initial()) {
    _missionExpensesService = missionExpensesService;
  }

  late MissionExpensesService _missionExpensesService;

  Future<void> getMissionExpense({required String missionUlid}) async {
    emit(const GetMissionExpenseState.loading());
    try {
      final missionExpense = await _missionExpensesService.get(
        ulid: missionUlid,
        includes: [
          'expenses.expenseCategory',
          'expenses.receipts',
        ],
      );

      emit(GetMissionExpenseState.loaded(missionExpense: missionExpense));
    } on Failure catch (e) {
      if (e.statusCode == 404) {
        emit(const GetMissionExpenseState.empty());
        return;
      }
      emit(GetMissionExpenseState.error(message: e.message));
    } catch (e) {
      emit(GetMissionExpenseState.error(message: e.toString()));
    }
  }
}
