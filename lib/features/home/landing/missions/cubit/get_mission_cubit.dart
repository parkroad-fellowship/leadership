import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_mission.dart';
import 'package:leadership/services/api/mission_service.dart';

part 'get_mission_state.dart';
part 'get_mission_cubit.freezed.dart';

class GetMissionCubit extends Cubit<GetMissionState> {
  GetMissionCubit({
    required MissionService missionService,
  }) : super(const GetMissionState.initial()) {
    _missionService = missionService;
  }

  late MissionService _missionService;

  Future<void> getMission({
    required String missionUlid,
  }) async {
    emit(const GetMissionState.loading());
    try {
      final mission = await _missionService.get(
        ulid: missionUlid,
        includes: [
          'school',
          'missionType',
          'school.schoolContacts.contactType',
          'loggedInMemberMissionSubscription',
          'weatherForecasts',
        ],
      );
      emit(GetMissionState.loaded(mission: mission));
    } on Failure catch (e) {
      emit(GetMissionState.error(e.message));
    } catch (e) {
      emit(GetMissionState.error(e.toString()));
    }
  }
}
