part of 'get_contact_types_cubit.dart';

@freezed
abstract class GetContactTypesState with _$GetContactTypesState {
  const factory GetContactTypesState.initial() = _Initial;
  const factory GetContactTypesState.loading() = _Loading;
  const factory GetContactTypesState.loaded({
    required List<PRFContactType> contactTypes,
  }) = _Loaded;
  const factory GetContactTypesState.error(String message) = _Error;
}
