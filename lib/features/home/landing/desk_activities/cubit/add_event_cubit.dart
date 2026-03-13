import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_event_type.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_event_dto.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/models/remote/prf_requisition_dto.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'add_event_state.dart';
part 'add_event_cubit.freezed.dart';

class AddEventCubit extends Cubit<AddEventState> {
  AddEventCubit({
    required EventService eventService,
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const AddEventState.initial()) {
    _eventService = eventService;
    _requisitionService = requisitionService;
    _hiveService = hiveService;
  }

  late EventService _eventService;
  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> addEvent({
    required String name,
    required DateTime startTime,
    required PRFResponsibleDesk responsibleDesk,
    required List<PRFMember> participants,
  }) async {
    emit(const AddEventState.loading());

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

      // Create the default requisition so that it's a one-step process
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

      emit(AddEventState.loaded(requisition: requisition));
    } on Failure catch (f) {
      emit(AddEventState.error(f.message));
    } catch (e) {
      emit(AddEventState.error(e.toString()));
    }
  }
}
