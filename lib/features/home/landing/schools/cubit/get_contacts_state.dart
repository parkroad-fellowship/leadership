part of 'get_contacts_cubit.dart';

@freezed
class GetContactsState with _$GetContactsState {
  const factory GetContactsState.initial() = _Initial;
  const factory GetContactsState.loading() = _Loading;
  const factory GetContactsState.loaded({required List<PRFContact> contacts}) =
      _Loaded;
  const factory GetContactsState.error(String message) = _Error;
}
