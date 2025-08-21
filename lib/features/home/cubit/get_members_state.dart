part of 'get_members_cubit.dart';

@freezed
abstract class GetMembersState with _$GetMembersState {
  const factory GetMembersState.initial() = _Initial;
  const factory GetMembersState.loading() = _Loading;
  const factory GetMembersState.loaded({required List<PRFMember> members}) =
      _Loaded;
  const factory GetMembersState.error(String message) = _Error;
}
