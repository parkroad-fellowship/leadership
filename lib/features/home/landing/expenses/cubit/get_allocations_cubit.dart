import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_allocation.dart';
import 'package:leadership/services/api/allocation_service.dart';

part 'get_allocations_state.dart';
part 'get_allocations_cubit.freezed.dart';

class GetAllocationsCubit extends Cubit<GetAllocationsState> {
  GetAllocationsCubit({
    required AllocationService allocationService,
  }) : super(const GetAllocationsState.initial()) {
    _allocationService = allocationService;
  }

  late AllocationService _allocationService;

  Future<void> getAllocations({
    required String accountingEventUlid,
  }) async {
    emit(const GetAllocationsState.loading());
    try {
      final allocations = await _allocationService.list(
        includes: ['accountingEvent'],
        filters: {
          'accounting_event_ulid': accountingEventUlid,
        },
      );

      if (allocations.isEmpty) {
        emit(const GetAllocationsState.empty());
      } else {
        emit(GetAllocationsState.loaded(allocations: allocations));
      }
    } on Failure catch (e) {
      emit(GetAllocationsState.error(e.message));
    } catch (e) {
      emit(GetAllocationsState.error(e.toString()));
    }
  }
}
