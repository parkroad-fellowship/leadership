part of 'request_review_cubit.dart';

@freezed
abstract class RequestReviewState with _$RequestReviewState {
  const factory RequestReviewState.initial() = _Initial;
  const factory RequestReviewState.loading() = _Loading;
  const factory RequestReviewState.loaded() = _Loaded;
  const factory RequestReviewState.error(String message) = _Error;
}
