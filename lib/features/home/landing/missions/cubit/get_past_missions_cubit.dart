import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_mission.dart';
import 'package:leadership/services/api/mission_service.dart';

part 'get_past_missions_state.dart';
part 'get_past_missions_cubit.freezed.dart';

class GetPastMissionsCubit extends Cubit<GetPastMissionsState> {
  GetPastMissionsCubit({
    required MissionService missionService,
  }) : super(const GetPastMissionsState.initial()) {
    _missionService = missionService;
  }

  late MissionService _missionService;

  Future<void> getPastMissions() async {
    emit(const GetPastMissionsState.loading());
    try {
      final missions = await _missionService.list(
        includes: [
          'school',
          'missionType',
          'school.schoolContacts.contactType',
        ],
        filters: {'past': true},
        orderBy: 'start_date',
        orderDirection: 'asc',
      );

      emit(GetPastMissionsState.loaded(missions: missions));
    } on Failure catch (e) {
      emit(GetPastMissionsState.error(e.message));
    } catch (e) {
      emit(GetPastMissionsState.error(e.toString()));
    }
  }
}
