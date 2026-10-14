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
import 'package:leadership/services/local_storage/hive/db/event_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';

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
  List<String> get defaultIncludes => ['accountingEvent'];

  @override
  Future<List<PRFEvent>> loadCachedList({Map<String, dynamic>? filters}) {
    return dbService.filterBy(
      (event) => [
        filters?['upcoming'] == null || event.endDate.isAfter(DateTime.now()),
        filters?['past'] == null || event.endDate.isBefore(DateTime.now()),
        filters?['search'] == null ||
            (event.name.toLowerCase().contains(
              (filters!['search'] as String).toLowerCase(),
            )),
        filters?['responsible_desks'] == null ||
            (filters?['responsible_desks'] as String)
                .split(',')
                .map(int.tryParse)
                .toList()
                .contains(event.accountingEvent?.responsibleDesk.apiKey),
      ],
    );
  }

  bool _historyMode = false;

  @override
  bool get crawlAllPages => !_historyMode;

  PRFRequisition? _lastCreatedRequisition;

  PRFRequisition? get lastCreatedRequisition => _lastCreatedRequisition;

  Future<void> loadUpcomingEvents() {
    _historyMode = false;
    return loadAll(
      filters: {
        'responsible_desks': _hiveService.responsibleDesks
            .map((desk) => desk.apiKey)
            .toList()
            .join(','),
        'upcoming': true,
      },
    );
  }

  Future<void> loadPastEvents() {
    _historyMode = true;
    // Newest first so page 1 is the most recent history.
    return loadAll(
      sortBy: '-start_date',
      limit: 30,
      filters: {
        'responsible_desks': _hiveService.responsibleDesks
            .map((desk) => desk.apiKey)
            .toList()
            .join(','),
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

      await dbService.persistEntity(event);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
    await _settleAfterSave();
  }

  /// The create-activity sheet uses the app-level cubit, which never ran
  /// [loadAll] and so has no Hive stream subscription: without this a
  /// successful save would leave it in `mutating` and the sheet spinning.
  /// A failed save has already emitted `error`, which this leaves alone.
  Future<void> _settleAfterSave() async {
    if (isClosed || state is! ResourceMutating<PRFEvent>) return;
    List<PRFEvent> items;
    try {
      items = await dbService.list();
    } catch (_) {
      items = currentItems;
    }
    if (isClosed || state is! ResourceMutating<PRFEvent>) return;
    emit(ResourceState.listLoaded(items: items));
  }
}
