import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';

part 'delete_receipt_cubit.freezed.dart';
part 'delete_receipt_state.dart';

class DeleteReceiptCubit extends Cubit<DeleteReceiptState> {
  DeleteReceiptCubit({
    required AllocationEntryService allocationEntryService,
  }) : super(const DeleteReceiptState.initial()) {
    _allocationEntryService = allocationEntryService;
  }

  late AllocationEntryService _allocationEntryService;

  Future<void> deleteReceipt({
    required String allocationEntryUlid,
    required String mediaUuid,
  }) async {
    emit(DeleteReceiptState.loading(mediaUuid: mediaUuid));

    try {
      await _allocationEntryService.deleteReceipt(
        allocationEntryUlid: allocationEntryUlid,
        mediaUuid: mediaUuid,
      );
      emit(DeleteReceiptState.loaded(mediaUuid: mediaUuid));
    } on Failure catch (f) {
      emit(DeleteReceiptState.error(f.message));
    } catch (e) {
      emit(DeleteReceiptState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const DeleteReceiptState.initial());
  }
}
