import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/services/api/school_service.dart';
import 'package:leadership/services/local_storage/hive/db/school_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

/// Cubit for loading past/completed missions grouped by school.
///
/// Separate from the flat mission list cubit so the "Past" and "By School"
/// tabs maintain independent state without overwriting each other's list.
class PastMissionResourceCubit extends ResourceCubit<PRFSchool> {
  PastMissionResourceCubit({
    required SchoolService schoolService,
    required SchoolHiveDbService hiveDbService,
  }) : super(service: schoolService, dbService: hiveDbService);

  @override
  List<String> get defaultIncludes => [
    'missions.school',
    'missions.schoolTerm',
    'missions.missionType',
  ];

  @override
  String? get defaultSortBy => 'name';

  @override
  Future<List<PRFSchool>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    final search = filters?['search'] as String?;
    if (search == null || search.isEmpty) {
      return dbService.list();
    }
    final query = search.toLowerCase();
    return dbService.filterBy(
      (school) => [school.name.toLowerCase().contains(query)],
    );
  }
}
