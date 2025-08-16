part of 'get_mission_expense_cubit.dart';

@freezed
class GetMissionExpenseState with _$GetMissionExpenseState {
  const factory GetMissionExpenseState.initial() = _Initial;
  const factory GetMissionExpenseState.loading() = _Loading;
  const factory GetMissionExpenseState.empty() = _Empty;
  const factory GetMissionExpenseState.loaded({
    required PRFMissionExpense missionExpense,
  }) = _Loaded;
  const factory GetMissionExpenseState.error({required String message}) =
      _Error;
}
