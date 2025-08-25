import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_allocation_entry_dto.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';

part 'add_allocation_entry_state.dart';
part 'add_allocation_entry_cubit.freezed.dart';

class AddAllocationEntryCubit extends Cubit<AddAllocationEntryState> {
  AddAllocationEntryCubit({
    required AllocationEntryService allocationEntryService,
  }) : super(const AddAllocationEntryState.initial()) {
    _allocationEntryService = allocationEntryService;
  }

  late AllocationEntryService _allocationEntryService;

  Future<void> addAllocationEntry({
    required String accountingEventUlid,
    required String allocationUlid,
    required String expenseCategoryUlid,
    required String memberUlid,
    required PRFEntryType entryType,
    required PRFChargeType chargeType,
    required int charge,
    required int unitCost,
    required int quantity,
    required String narration,
    required String confirmationMessage,
  }) async {
    emit(const AddAllocationEntryState.loading());

    try {
      await _allocationEntryService.create(
        data: PRFAllocationEntryDTO(
          accountingEventUlid: accountingEventUlid,
          allocationUlid: allocationUlid,
          expenseCategoryUlid: expenseCategoryUlid,
          memberUlid: memberUlid,
          entryType: entryType,
          chargeType: chargeType,
          charge: charge,
          unitCost: unitCost,
          quantity: quantity,
          narration: narration,
          confirmationMessage: confirmationMessage,
        ).toJson(),
      );

      emit(const AddAllocationEntryState.success());
    } on Failure catch (f) {
      emit(AddAllocationEntryState.error(f.message));
    } catch (e) {
      emit(AddAllocationEntryState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const AddAllocationEntryState.initial());
  }
}
