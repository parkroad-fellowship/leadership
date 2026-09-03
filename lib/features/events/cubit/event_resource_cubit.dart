import 'package:leadership/enums/prf_event_type.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/models/remote/prf_event_dto.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/models/remote/prf_requisition_dto.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/db/event_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';

class EventResourceCubit extends ResourceCubit<PRFEvent> {
  EventResourceCubit({
    required EventService eventService,
    required this._requisitionService,
    required this._hiveService,
    required EventHiveDbService hiveDbService,
  }) : _eventService = eventService,
       super(service: eventService, dbService: hiveDbService);

  final EventService _eventService;
  final RequisitionService _requisitionService;
  final HiveService _hiveService;

  @override
  Future<List<PRFEvent>> loadCachedList({Map<String, dynamic>? filters}) async {
    return dbService.list();
  }

  PRFRequisition? _lastCreatedRequisition;

  PRFRequisition? get lastCreatedRequisition => _lastCreatedRequisition;

  Future<void> loadUpcomingEvents() {
    return loadAll(
      filters: {
        'responsible_desks': PRFResponsibleDesk.apiKeys(
          PRFResponsibleDesk.fromRoles(_hiveService.memberRoles),
        ),
        if (Misc.userCan(PRFPermissions.viewAnyCommitteeItem))
          PRFLeadershipGroup.campCommittee.apiKey: true,
        'upcoming': true,
      },
    );
  }

  Future<void> loadPastEvents() {
    return loadAll(
      orderBy: 'start_date',
      filters: {
        'responsible_desks': PRFResponsibleDesk.apiKeys(
          PRFResponsibleDesk.fromRoles(_hiveService.memberRoles),
        ),
        if (Misc.userCan(PRFPermissions.viewAnyCommitteeItem))
          PRFLeadershipGroup.campCommittee.apiKey: true,
        'past': true,
      },
    );
  }

  Future<void> addEvent({
    required String name,
    required DateTime startTime,
    required PRFResponsibleDesk responsibleDesk,
    required List<PRFMember> participants,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.create,
      ),
    );

    try {
      final event = await _eventService.create(
        data: PRFEventDTO(
          name: name,
          description: name,
          startDate: startTime.toUtc().toIso8601String().split('T')[0],
          startTime: startTime.toUtc().toIso8601String().split('T')[1],
          endDate: startTime
              .add(const Duration(days: 3))
              .toUtc()
              .toIso8601String()
              .split('T')[0],
          endTime: startTime
              .add(const Duration(days: 3))
              .toUtc()
              .toIso8601String()
              .split('T')[1],
          responsibleDesk: responsibleDesk.apiKey,
          eventType: PRFEventType.leadership.apiKey,
          participantMemberUlids: participants.map((e) => e.ulid).toList(),
        ).toJson(),
        includes: ['accountingEvent', 'participants'],
      );

      final member = _hiveService.retrieveMember()!;

      final requisition = await _requisitionService.create(
        data: PRFRequisitionDTO(
          memberUlid: member.ulid,
          accountingEventUlid: event.accountingEvent!.ulid,
          requisitionDate: DateTime.now(),
          responsibleDesk: responsibleDesk,
          remarks: 'Initial requisition for event ${event.name}',
        ).toJson(),
      );

      _lastCreatedRequisition = requisition;

      emit(
        ResourceState.mutated(
          items: [event, ...currentItems],
          operation: ResourceOperation.create,
          item: event,
        ),
      );
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }
}
