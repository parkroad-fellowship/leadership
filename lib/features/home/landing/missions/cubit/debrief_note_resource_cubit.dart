import 'package:leadership/models/remote/prf_debrief_note.dart';
import 'package:leadership/services/api/debrief_note_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class DebriefNoteResourceCubit extends ResourceCubit<PRFDebriefNote> {
  DebriefNoteResourceCubit({
    required DebriefNoteService missionDebriefNoteService,
  }) : super(service: missionDebriefNoteService);

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      orderBy: 'created_at',
      orderDirection: 'desc',
      limit: 200,
    );
  }

  Future<void> createNote({
    required String missionUlid,
    required String note,
  }) {
    return create(
      data: {
        'mission_ulid': missionUlid,
        'note': note,
      },
    );
  }

  Future<void> updateNote({
    required String noteUlid,
    required String note,
  }) {
    return update(
      id: noteUlid,
      data: {'note': note},
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
