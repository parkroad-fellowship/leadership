import 'package:leadership/models/remote/prf_mission_debrief_note.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionDebriefNoteService extends BaseAPIService<PRFMissionDebriefNote> {
  @override
  String get endpoint => '/debrief-notes';

  @override
  PRFMissionDebriefNote createFromJson(Map<String, dynamic> json) {
    return PRFMissionDebriefNote.fromJson(json);
  }

  @override
  List<PRFMissionDebriefNote> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMissionDebriefNote>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMissionDebriefNote.fromJson)
        .toList(growable: false);
  }
}
