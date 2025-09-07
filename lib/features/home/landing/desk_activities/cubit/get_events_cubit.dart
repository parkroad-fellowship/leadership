import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/utils/_index.dart';

part 'get_events_state.dart';
part 'get_events_cubit.freezed.dart';

class GetEventsCubit extends Cubit<GetEventsState> {
  GetEventsCubit({
    required EventService eventService,
    required HiveService hiveService,
  }) : super(const GetEventsState.initial()) {
    _eventService = eventService;
    _hiveService = hiveService;
  }

  late EventService _eventService;
  late HiveService _hiveService;

  Future<void> getUpcomingEvents() async {
    emit(const GetEventsState.loading());
    try {
      final events = await _eventService.list(
        includes: [
          'posters',
          'accountingEvent',
        ],
        filters: {
          'responsible_desks': PRFResponsibleDesk.apiKeys(
            PRFResponsibleDesk.fromRoles(_hiveService.memberRoles),
          ),
          // Select camp team by default
          if (Misc.userCan(PRFPermissions.viewAnyCommitteeItem))
            PRFLeadershipGroup.campCommittee.apiKey: true,
          'upcoming': true,
        },
      );
      if (events.isEmpty) {
        emit(const GetEventsState.empty());
      } else {
        emit(GetEventsState.loaded(events: events));
      }
    } on Failure catch (e) {
      emit(GetEventsState.error(e.message));
    } catch (e) {
      emit(GetEventsState.error(e.toString()));
    }
  }
}
