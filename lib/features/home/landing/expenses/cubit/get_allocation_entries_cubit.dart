import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';

part 'get_allocation_entries_state.dart';
part 'get_allocation_entries_cubit.freezed.dart';

class GetAllocationEntriesCubit extends Cubit<GetAllocationEntriesState> {
  GetAllocationEntriesCubit({
    required AllocationEntryService allocationEntryService,
  }) : super(const GetAllocationEntriesState.initial()) {
    _allocationEntryService = allocationEntryService;
  }

  late AllocationEntryService _allocationEntryService;

  Future<void> getAllocationEntries({
    required String accountingEventUlid,
  }) async {
    emit(const GetAllocationEntriesState.loading());
    try {
      final entries = await _allocationEntryService.list(
        includes: [
          'expenseCategory',
          'member',
          'accountingEvent',
          'receipts',
        ],
        filters: {
          'accounting_event_ulid': accountingEventUlid,
        },
      );

      if (entries.isEmpty) {
        emit(const GetAllocationEntriesState.empty());
      } else {
        emit(GetAllocationEntriesState.loaded(entries: entries));
      }
    } on Failure catch (e) {
      emit(GetAllocationEntriesState.error(e.message));
    } catch (e) {
      emit(GetAllocationEntriesState.error(e.toString()));
    }
  }

  Future<void> refreshAllocationEntries({
    required String accountingEventUlid,
  }) async {
    await getAllocationEntries(accountingEventUlid: accountingEventUlid);
  }
}
