import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/models/remote/prf_refund_dto.dart';
import 'package:leadership/services/api/refund_service.dart';

part 'add_mission_refund_state.dart';
part 'add_mission_refund_cubit.freezed.dart';

class AddMissionRefundCubit extends Cubit<AddMissionRefundState> {
  AddMissionRefundCubit({
    required RefundService refundService,
  }) : super(const AddMissionRefundState.initial()) {
    _refundService = refundService;
  }

  late RefundService _refundService;

  Future<void> addMissionRefund({
    required String accountingEventUlid,
    required int amount,
    required String confirmationMessage,
  }) async {
    emit(const AddMissionRefundState.loading());
    try {
      final refund = await _refundService.create(
        data: PRFRefundDTO(
          accountingEventUlid: accountingEventUlid,
          amount: amount,
          confirmationMessage: confirmationMessage,
        ).toJson(),
      );
      emit(AddMissionRefundState.loaded(refund: refund));
    } catch (e) {
      emit(AddMissionRefundState.error(e.toString()));
    }
  }
}
