import 'package:leadership/models/remote/prf_debrief_note.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class DebriefNoteService extends BaseAPIService<PRFDebriefNote> {
  @override
  String get endpoint => '/debrief-notes';

  @override
  PRFDebriefNote createFromJson(Map<String, dynamic> json) {
    return PRFDebriefNote.fromJson(json);
  }

  @override
  List<PRFDebriefNote> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFDebriefNote>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFDebriefNote.fromJson)
        .toList(growable: false);
  }
}
