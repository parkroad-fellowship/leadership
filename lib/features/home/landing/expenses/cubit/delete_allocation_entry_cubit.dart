import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';

part 'delete_allocation_entry_state.dart';
part 'delete_allocation_entry_cubit.freezed.dart';

class DeleteAllocationEntryCubit extends Cubit<DeleteAllocationEntryState> {
  DeleteAllocationEntryCubit({
    required AllocationEntryService allocationEntryService,
  }) : super(const DeleteAllocationEntryState.initial()) {
    _allocationEntryService = allocationEntryService;
  }

  late AllocationEntryService _allocationEntryService;

  Future<void> deleteAllocationEntry({
    required String allocationEntryUlid,
  }) async {
    emit(const DeleteAllocationEntryState.loading());

    try {
      await _allocationEntryService.delete(ulid: allocationEntryUlid);
      emit(const DeleteAllocationEntryState.loaded());
    } on Failure catch (f) {
      emit(DeleteAllocationEntryState.error(f.message));
    } catch (e) {
      emit(DeleteAllocationEntryState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const DeleteAllocationEntryState.initial());
  }
}
