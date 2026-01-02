part of 'delete_receipt_cubit.dart';

@freezed
abstract class DeleteReceiptState with _$DeleteReceiptState {
  const factory DeleteReceiptState.initial() = _Initial;
  const factory DeleteReceiptState.loading({required String mediaUuid}) =
      _Loading;
  const factory DeleteReceiptState.loaded({required String mediaUuid}) =
      _Loaded;
  const factory DeleteReceiptState.error(String message) = _Error;
}
