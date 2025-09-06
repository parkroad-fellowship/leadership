import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/api/member_service.dart';

part 'get_members_state.dart';
part 'get_members_cubit.freezed.dart';

class GetMembersCubit extends Cubit<GetMembersState> {
  GetMembersCubit({
    required MemberService memberService,
  }) : super(const GetMembersState.initial()) {
    _memberService = memberService;
  }

  late MemberService _memberService;

  Future<void> getMembers({
    List<PRFLeadershipGroup>? groups,
  }) async {
    emit(const GetMembersState.loading());
    try {
      final members = await _memberService.list(
        filters: {
          if (groups != null)
            ...groups
                .map((group) => {group.apiKey: true})
                .reduce((a, b) => {...a, ...b}),
        },
      );
      emit(GetMembersState.loaded(members: members));
    } on Failure catch (f) {
      emit(GetMembersState.error(f.message));
    } catch (e) {
      emit(GetMembersState.error(e.toString()));
    }
  }
}
