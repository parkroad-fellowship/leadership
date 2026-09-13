import 'package:leadership/models/remote/prf_debrief_note.dart';
import 'package:leadership/models/remote/prf_debrief_note_dto.dart';
import 'package:leadership/services/api/debrief_note_service.dart';
import 'package:leadership/services/local_storage/hive/db/debrief_note_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class DebriefNoteResourceCubit extends ResourceCubit<PRFDebriefNote> {
  DebriefNoteResourceCubit({
    required DebriefNoteService missionDebriefNoteService,
    required DebriefNoteHiveDbService hiveDbService,
  }) : super(service: missionDebriefNoteService, dbService: hiveDbService);

  @override
  Future<List<PRFDebriefNote>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.filterBy(
      (item) => [
        filters?['mission_ulid'] == null ||
            item.mission?.ulid == (filters?['mission_ulid'] as String),
      ],
    );
  }

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      includes: ['mission'],
      sortBy: 'created_at',
      limit: 200,
    );
  }

  Future<void> createNote({
    required String missionUlid,
    required String note,
  }) {
    final dto = PRFDebriefNoteDTO(
      missionUlid: missionUlid,
      note: note,
    );

    return create(
      data: dto.toJson(),
    );
  }

  Future<void> updateNote({
    required String noteUlid,
    required String missionUlid,
    required String note,
  }) {
    final dto = PRFDebriefNoteDTO(
      missionUlid: missionUlid,
      note: note,
    );

    return update(
      id: noteUlid,
      data: dto.toJson(),
      matchById: (item) => item.ulid == noteUlid,
    );
  }

  Future<void> deleteNote({required String noteUlid}) {
    return delete(
      ulid: noteUlid,
      matchById: (item) => item.ulid == noteUlid,
    );
  }
}
