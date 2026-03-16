import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_member_create_dto.dart';
import 'package:leadership/models/remote/prf_member_update_dto.dart';
import 'package:leadership/services/api/member_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MemberResourceCubit extends ResourceCubit<PRFMember> {
  MemberResourceCubit({required MemberService memberService})
    : super(service: memberService);

  @override
  List<String> get defaultIncludes => [
    'profession',
    'maritalStatus',
    'church',
    'profilePicture',
    'departments',
    'gifts',
  ];

  Future<void> createMember({required PRFMemberCreateDTO dto}) {
    return create(data: dto.toJson());
  }

  Future<void> updateMember({
    required String ulid,
    required PRFMemberUpdateDTO dto,
  }) {
    return update(
      id: ulid,
      data: dto.toJson(),
      matchById: (m) => m.ulid == ulid,
    );
  }
}
