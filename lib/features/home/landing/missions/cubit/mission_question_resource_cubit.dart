import 'package:leadership/models/remote/mission/prf_mission_question.dart';
import 'package:leadership/models/remote/mission/prf_mission_question_dto.dart';
import 'package:leadership/services/api/mission_question_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_question_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionQuestionResourceCubit extends ResourceCubit<PRFMissionQuestion> {
  MissionQuestionResourceCubit({
    required MissionQuestionService missionQuestionService,
    required MissionQuestionHiveDbService hiveDbService,
  }) : super(service: missionQuestionService, dbService: hiveDbService);

  @override
  Future<List<PRFMissionQuestion>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      orderBy: 'created_at',
      orderDirection: 'desc',
      limit: 200,
    );
  }

  Future<void> createQuestion({
    required String missionUlid,
    required String question,
  }) {
    final dto = PRFMissionQuestionDTO(
      missionUlid: missionUlid,
      question: question,
    );

    return create(
      data: dto.toJson(),
    );
  }

  Future<void> updateQuestion({
    required String questionUlid,
    required String missionUlid,
    required String question,
  }) {
    final dto = PRFMissionQuestionDTO(
      missionUlid: missionUlid,
      question: question,
    );

    return update(
      id: questionUlid,
      data: dto.toJson(),
      matchById: (item) => item.ulid == questionUlid,
    );
  }

  Future<void> deleteQuestion({required String questionUlid}) {
    return delete(
      ulid: questionUlid,
      matchById: (item) => item.ulid == questionUlid,
    );
  }
}
