import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_member_create_dto.dart';
import 'package:leadership/models/remote/prf_member_update_dto.dart';
import 'package:leadership/services/api/member_service.dart';
import 'package:leadership/services/local_storage/hive/db/member_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MemberResourceCubit extends ResourceCubit<PRFMember> {
  MemberResourceCubit({
    required MemberService memberService,
    required MemberHiveDbService hiveDbService,
  }) : super(service: memberService, dbService: hiveDbService);

  @override
  List<String> get defaultIncludes => [
    'profession',
    'maritalStatus',
    'church',
    'profilePicture',
    'departments',
    'gifts',
  ];

  @override
  Future<List<PRFMember>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

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

  Future<void> getMembers({List<PRFLeadershipGroup>? groups}) {
    final filters = <String, dynamic>{};
    if (groups != null && groups.isNotEmpty) {
      filters.addAll(
        groups
            .map((group) => {group.apiKey: true})
            .reduce((a, b) => {...a, ...b}),
      );
    }
    return loadAll(filters: filters);
  }
}
