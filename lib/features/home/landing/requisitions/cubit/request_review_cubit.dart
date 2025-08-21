import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/requisition_service.dart';

part 'request_review_state.dart';
part 'request_review_cubit.freezed.dart';

class RequestReviewCubit extends Cubit<RequestReviewState> {
  RequestReviewCubit({
    required RequisitionService requisitionService,
  }) : super(const RequestReviewState.initial()) {
    _requisitionService = requisitionService;
  }

  late RequisitionService _requisitionService;

  Future<void> requestReview({
    required String ulid,
    required String approverUlid,
  }) async {
    emit(const RequestReviewState.loading());
    try {
      final success = await _requisitionService.requestReview(
        ulid: ulid,
        approverUlid: approverUlid,
      );
      if (success) {
        emit(const RequestReviewState.loaded());
      } else {
        emit(const RequestReviewState.error('Failed to request review.'));
      }
    } on Failure catch (f) {
      emit(RequestReviewState.error(f.message));
    } catch (e) {
      emit(RequestReviewState.error(e.toString()));
    }
  }
}
