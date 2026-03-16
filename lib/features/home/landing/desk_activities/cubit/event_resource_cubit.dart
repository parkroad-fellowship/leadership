import 'package:leadership/enums/prf_event_type.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/models/remote/prf_event_dto.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/models/remote/prf_requisition_dto.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';

class EventResourceCubit extends ResourceCubit<PRFEvent> {
  EventResourceCubit({
    required EventService eventService,
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : _eventService = eventService,
       _requisitionService = requisitionService,
       _hiveService = hiveService,
       super(service: eventService);

  final EventService _eventService;
  final RequisitionService _requisitionService;
  final HiveService _hiveService;

  PRFRequisition? _lastCreatedRequisition;

  PRFRequisition? get lastCreatedRequisition => _lastCreatedRequisition;

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
