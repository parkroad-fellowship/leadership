import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_mission.dart';
import 'package:leadership/services/api/mission_service.dart';

part 'get_missions_state.dart';
part 'get_missions_cubit.freezed.dart';

class GetMissionsCubit extends Cubit<GetMissionsState> {
  GetMissionsCubit({
    required MissionService missionService,
  }) : super(const GetMissionsState.initial()) {
    _missionService = missionService;
  }

  late MissionService _missionService;

  Future<void> getMissions() async {
    emit(const GetMissionsState.loading());
    try {
      final missions = await _missionService.list(
        includes: [
          'school',
          'missionType',
          'school.schoolContacts.contactType',
          'accountingEvent',
        ],
        filters: {'upcoming': true},
        orderBy: 'start_date',
        orderDirection: 'asc',
      );

      emit(GetMissionsState.loaded(missions: missions));
    } on Failure catch (e) {
      emit(GetMissionsState.error(e.message));
    } catch (e) {
      emit(GetMissionsState.error(e.toString()));
    }
  }
}
