import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/models/remote/prf_requisition_dto.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';

class RequisitionResourceCubit extends ResourceCubit<PRFRequisition> {
  RequisitionResourceCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : _requisitionService = requisitionService,
       _hiveService = hiveService,
       super(service: requisitionService);

  final RequisitionService _requisitionService;
  final HiveService _hiveService;

  String? _lastAccountingEventUlid;
  String? _lastRequisitionUlid;

  PRFRequisition? get currentRequisition {
    if (currentItems.isEmpty) {
      return null;
    }
    return currentItems.first;
  }

  @override
  List<String> get defaultIncludes => [
    'member',
    'appointedApprover',
    'approvedBy',
    'paymentInstruction',
  ];

  Future<void> loadForAccountingEvent({required String accountingEventUlid}) {
    _lastAccountingEventUlid = accountingEventUlid;
    _lastRequisitionUlid = null;
    return loadAll(filters: {'accounting_event_ulid': accountingEventUlid});
  }

  Future<void> loadRequisition({required String requisitionUlid}) async {
    _lastRequisitionUlid = requisitionUlid;
    emit(const ResourceState.listLoading());
    try {
      final requisition = await _requisitionService.get(
        ulid: requisitionUlid,
        includes: [
          ...defaultIncludes,
          'accountingEvent',
        ],
      );
      _lastAccountingEventUlid = requisition.accountingEvent?.ulid;
      emit(ResourceState.listLoaded(items: [requisition]));
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }

  Future<void> createRequisition({
    required PRFAccountingEvent accountingEvent,
    required String remarks,
  }) {
    _lastAccountingEventUlid = accountingEvent.ulid;
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

      await _requisitionService.update(
        id: requisitionUlid,
        data: PRFRequisitionDTO(
          memberUlid: member.ulid,
          accountingEventUlid: accountingEvent.ulid,
          responsibleDesk: accountingEvent.responsibleDesk,
          requisitionDate: requisitionDate,
          remarks: remarks,
        ).toJson(),
      );

      emit(
        ResourceState.mutated(
          items: currentItems,
          operation: ResourceOperation.update,
        ),
      );

      if (_lastRequisitionUlid != null) {
        await loadRequisition(requisitionUlid: _lastRequisitionUlid!);
      } else if (_lastAccountingEventUlid != null) {
        await loadForAccountingEvent(
          accountingEventUlid: _lastAccountingEventUlid!,
        );
      }
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
      emit(
        ResourceState.mutated(
          items: currentItems,
          operation: ResourceOperation.update,
        ),
      );
      if (_lastRequisitionUlid != null) {
        await loadRequisition(requisitionUlid: _lastRequisitionUlid!);
      } else if (_lastAccountingEventUlid != null) {
        await loadForAccountingEvent(
          accountingEventUlid: _lastAccountingEventUlid!,
        );
      }
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
      emit(
        ResourceState.mutated(
          items: currentItems,
          operation: ResourceOperation.update,
        ),
      );
      if (_lastRequisitionUlid != null) {
        await loadRequisition(requisitionUlid: _lastRequisitionUlid!);
      } else if (_lastAccountingEventUlid != null) {
        await loadForAccountingEvent(
          accountingEventUlid: _lastAccountingEventUlid!,
        );
      }
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
      emit(
        ResourceState.mutated(
          items: currentItems,
          operation: ResourceOperation.update,
        ),
      );
      if (_lastRequisitionUlid != null) {
        await loadRequisition(requisitionUlid: _lastRequisitionUlid!);
      } else if (_lastAccountingEventUlid != null) {
        await loadForAccountingEvent(
          accountingEventUlid: _lastAccountingEventUlid!,
        );
      }
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
      emit(
        ResourceState.mutated(
          items: currentItems,
          operation: ResourceOperation.update,
        ),
      );
      if (_lastRequisitionUlid != null) {
        await loadRequisition(requisitionUlid: _lastRequisitionUlid!);
      } else if (_lastAccountingEventUlid != null) {
        await loadForAccountingEvent(
          accountingEventUlid: _lastAccountingEventUlid!,
        );
      }
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }
}
