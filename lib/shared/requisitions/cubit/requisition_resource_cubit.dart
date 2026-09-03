import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/models/remote/prf_requisition_dto.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';

class RequisitionResourceCubit extends ResourceCubit<PRFRequisition> {
  RequisitionResourceCubit({
    required RequisitionService requisitionService,
    required RequisitionHiveDbService hiveDbService,
    required this._hiveService,
  }) : _requisitionService = requisitionService,
       super(service: requisitionService, dbService: hiveDbService);

  final RequisitionService _requisitionService;
  final HiveService _hiveService;

  @override
  List<String> get defaultIncludes => [
    'member',
    'appointedApprover',
    'approvedBy',
    'paymentInstruction',
  ];

  @override
  Future<List<PRFRequisition>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.filterBy(
      (requisition) => [
        filters?['approval_status'] == null ||
            requisition.approvalStatus.apiKey ==
                (filters?['approval_status'] as int),
        filters?['responsible_desks'] == null ||
            (filters?['responsible_desks'] as List<int>).contains(
              requisition.responsibleDesk.apiKey,
            ),
        filters?['appointed_approver_ulid'] == null ||
            requisition.appointedApprover?.ulid ==
                (filters?['appointed_approver_ulid'] as String),
      ],
    );
  }

  Future<void> loadForAccountingEvent({required String accountingEventUlid}) {
    return loadAll(filters: {'accounting_event_ulid': accountingEventUlid});
  }

  Future<void> loadApprovalRequisitions() {
    final member = _hiveService.retrieveMember()!;
    return loadAll(
      filters: {
        'appointed_approver_ulid': member.ulid,
        'approval_status': PRFApprovalStatus.underReview.apiKey,
      },
    );
  }

  Future<void> loadClosedRequisitions() {
    final member = _hiveService.retrieveMember()!;
    return loadAll(
      filters: {
        'appointed_approver_ulid': member.ulid,
        'responsible_desks': _hiveService.responsibleDesks
            .map((desk) => desk.apiKey)
            .toList()
            .join(','),
        'approval_statuses': [
          PRFApprovalStatus.approved.apiKey,
          PRFApprovalStatus.rejected.apiKey,
        ].join(','),
      },
    );
  }

  Future<void> loadDraftRequisitions() {
    return loadAll(
      filters: {
        'responsible_desks': _hiveService.responsibleDesks
            .map((desk) => desk.apiKey)
            .toList()
            .join(','),
        'approval_statuses': [
          PRFApprovalStatus.pending.apiKey,
        ].join(','),
      },
    );
  }

  Future<void> createRequisition({
    required PRFAccountingEvent accountingEvent,
    required String remarks,
  }) {
    final member = _hiveService.retrieveMember();
    return create(
      data: PRFRequisitionDTO(
        memberUlid: member!.ulid,
        accountingEventUlid: accountingEvent.ulid,
        responsibleDesk: accountingEvent.responsibleDesk,
        requisitionDate: DateTime.now(),
        remarks: remarks,
      ).toJson(),
    );
  }

  Future<void> updateRequisition({
    required String requisitionUlid,
    required PRFAccountingEvent accountingEvent,
    required DateTime requisitionDate,
    required String remarks,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );

    try {
      final member = _hiveService.retrieveMember()!;

      final requisition = await _requisitionService.update(
        id: requisitionUlid,
        data: PRFRequisitionDTO(
          memberUlid: member.ulid,
          accountingEventUlid: accountingEvent.ulid,
          responsibleDesk: accountingEvent.responsibleDesk,
          requisitionDate: requisitionDate,
          remarks: remarks,
        ).toJson(),
      );

      // Persist the update — the DB stream re-emits the list state.
      await dbService.persistEntity(requisition);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }

  Future<void> requestReview({
    required String requisitionUlid,
    required String approverUlid,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );
    try {
      await _requisitionService.requestReview(
        ulid: requisitionUlid,
        approverUlid: approverUlid,
      );
      // The action only returns a bool (nothing was written to Hive), so
      // refresh just the affected requisition and persist it — the DB stream
      // re-emits the list state.
      await _refreshRequisition(requisitionUlid);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }

  Future<void> approveRequisition({
    required String requisitionUlid,
    String? approvalNotes,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );
    try {
      final member = _hiveService.retrieveMember()!;
      await _requisitionService.approveRequisition(
        ulid: requisitionUlid,
        approverUlid: member.ulid,
        approvalNotes: approvalNotes,
      );
      // The action only returns a bool (nothing was written to Hive), so
      // refresh just the affected requisition and persist it — the DB stream
      // re-emits the list state.
      await _refreshRequisition(requisitionUlid);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }

  Future<void> rejectRequisition({
    required String requisitionUlid,
    required String approvalNotes,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );
    try {
      final member = _hiveService.retrieveMember()!;
      await _requisitionService.rejectRequisition(
        ulid: requisitionUlid,
        approverUlid: member.ulid,
        approvalNotes: approvalNotes,
      );
      // The action only returns a bool (nothing was written to Hive), so
      // refresh just the affected requisition and persist it — the DB stream
      // re-emits the list state.
      await _refreshRequisition(requisitionUlid);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }

  Future<void> recallRequisition({
    required String requisitionUlid,
    required String approvalNotes,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );
    try {
      final member = _hiveService.retrieveMember()!;
      await _requisitionService.recallRequisition(
        ulid: requisitionUlid,
        approverUlid: member.ulid,
        approvalNotes: approvalNotes,
      );
      // The action only returns a bool (nothing was written to Hive), so
      // refresh just the affected requisition and persist it — the DB stream
      // re-emits the list state.
      await _refreshRequisition(requisitionUlid);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }

  /// The action only returns a bool (nothing was written to Hive), so
  /// refresh just the affected requisition and persist it — the DB stream
  /// re-emits the list state.
  Future<void> _refreshRequisition(String requisitionUlid) async {
    final requisition = await _requisitionService.get(
      ulid: requisitionUlid,
      includes: defaultIncludes,
    );
    await dbService.persistEntity(requisition);
  }
}
