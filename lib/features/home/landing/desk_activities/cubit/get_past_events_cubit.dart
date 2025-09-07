import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/utils/misc.dart';

part 'get_past_events_state.dart';
part 'get_past_events_cubit.freezed.dart';

class GetPastEventsCubit extends Cubit<GetPastEventsState> {
  GetPastEventsCubit({
    required EventService eventService,
    required HiveService hiveService,
  }) : super(const GetPastEventsState.initial()) {
    _eventService = eventService;
    _hiveService = hiveService;
  }

  late EventService _eventService;
  late HiveService _hiveService;

  Future<void> getPastEvents() async {
    emit(const GetPastEventsState.loading());
    try {
      final events = await _eventService.list(
        includes: [
          'posters',
          'accountingEvent',
        ],
        orderBy: 'start_date',
        orderDirection: 'desc',
        filters: {
          'responsible_desks': PRFResponsibleDesk.apiKeys(
            PRFResponsibleDesk.fromRoles(_hiveService.memberRoles),
          ),
          // Select camp team by default
          if (Misc.userCan(PRFPermissions.viewAnyCommitteeItem))
            PRFLeadershipGroup.campCommittee.apiKey: true,
          'past': true,
        },
      );
      if (events.isEmpty) {
        emit(const GetPastEventsState.empty());
      } else {
        emit(
          GetPastEventsState.loaded(
            events: events,
          ),
        );
      }
    } on Failure catch (e) {
      emit(GetPastEventsState.error(e.message));
    } catch (e) {
      emit(GetPastEventsState.error(e.toString()));
    }
  }
}
