import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/crud/single_resource_cubit.dart';

class RequisitionDetailCubit extends SingleResourceCubit<PRFRequisition> {
  RequisitionDetailCubit({
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
    'accountingEvent',
  ];

  Future<void> requestReview({
    required String requisitionUlid,
    required String approverUlid,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItem != null ? [currentItem!] : [],
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
          items: currentItem != null ? [currentItem!] : [],
          operation: ResourceOperation.update,
          item: currentItem,
        ),
      );
      await loadOne(
        id: requisitionUlid,
        matchById: (item) => item.ulid == requisitionUlid,
        refresh: true,
      );
    } on Failure catch (e) {
      emit(ResourceState.itemError(message: e.message, item: currentItem));
    } catch (e) {
      emit(ResourceState.itemError(message: e.toString(), item: currentItem));
    }
  }

  Future<void> approveRequisition({
    required String requisitionUlid,
    String? approvalNotes,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItem != null ? [currentItem!] : [],
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
          items: currentItem != null ? [currentItem!] : [],
          operation: ResourceOperation.update,
          item: currentItem,
        ),
      );
      await loadOne(
        id: requisitionUlid,
        matchById: (item) => item.ulid == requisitionUlid,
        refresh: true,
      );
    } on Failure catch (e) {
      emit(ResourceState.itemError(message: e.message, item: currentItem));
    } catch (e) {
      emit(ResourceState.itemError(message: e.toString(), item: currentItem));
    }
  }

  Future<void> rejectRequisition({
    required String requisitionUlid,
    required String approvalNotes,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItem != null ? [currentItem!] : [],
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
          items: currentItem != null ? [currentItem!] : [],
          operation: ResourceOperation.update,
          item: currentItem,
        ),
      );
      await loadOne(
        id: requisitionUlid,
        matchById: (item) => item.ulid == requisitionUlid,
        refresh: true,
      );
    } on Failure catch (e) {
      emit(ResourceState.itemError(message: e.message, item: currentItem));
    } catch (e) {
      emit(ResourceState.itemError(message: e.toString(), item: currentItem));
    }
  }

  Future<void> recallRequisition({
    required String requisitionUlid,
    required String approvalNotes,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItem != null ? [currentItem!] : [],
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
          items: currentItem != null ? [currentItem!] : [],
          operation: ResourceOperation.update,
          item: currentItem,
        ),
      );
      await loadOne(
        id: requisitionUlid,
        matchById: (item) => item.ulid == requisitionUlid,
        refresh: true,
      );
    } on Failure catch (e) {
      emit(ResourceState.itemError(message: e.message, item: currentItem));
    } catch (e) {
      emit(ResourceState.itemError(message: e.toString(), item: currentItem));
    }
  }
}
