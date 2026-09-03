import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_allocation_entry_dto.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';
import 'package:leadership/services/local_storage/hive/db/allocation_entry_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/services/media_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';

class AllocationEntryResourceCubit extends ResourceCubit<PRFAllocationEntry> {
  AllocationEntryResourceCubit({
    required AllocationEntryService allocationEntryService,
    required this._hiveService,
    required this._mediaService,
    required AllocationEntryHiveDbService hiveDbService,
  }) : _allocationEntryService = allocationEntryService,
       super(service: allocationEntryService, dbService: hiveDbService);

  final AllocationEntryService _allocationEntryService;
  final HiveService _hiveService;
  final MediaService _mediaService;

  @override
  Future<List<PRFAllocationEntry>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> addAllocationEntry({
    required String accountingEventUlid,
    required String expenseCategoryUlid,
    required PRFEntryType entryType,
    required PRFChargeType chargeType,
    required int charge,
    required int unitCost,
    required int quantity,
    required String narration,
    required String confirmationMessage,
    required List<PRFMediaDTO> receiptDTOs,
  }) async {
    final member = _hiveService.retrieveMember()!;

    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.create,
      ),
    );

    final PRFAllocationEntry createdEntry;
    try {
      createdEntry = await _allocationEntryService.create(
        data: PRFAllocationEntryDTO(
          accountingEventUlid: accountingEventUlid,
          expenseCategoryUlid: expenseCategoryUlid,
          memberUlid: member.ulid,
          entryType: entryType,
          chargeType: chargeType,
          charge: charge,
          unitCost: unitCost,
          quantity: quantity,
          narration: narration,
          confirmationMessage: confirmationMessage,
        ).toJson(),
        includes: defaultIncludes,
      );
      await dbService.persistEntity(createdEntry);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
      return;
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
      return;
    }

    if (receiptDTOs.isEmpty) {
      return;
    }

    for (final receiptDTO in receiptDTOs) {
      await _mediaService.uploadFile(
        imageDTO: receiptDTO.copyWith(modelUlid: createdEntry.ulid),
      );
    }
  }

  Future<void> updateAllocationEntry({
    required String allocationEntryUlid,
    required String accountingEventUlid,
    required String expenseCategoryUlid,
    required PRFEntryType entryType,
    required PRFChargeType chargeType,
    required int charge,
    required int unitCost,
    required int quantity,
    required String narration,
    required String confirmationMessage,
    required List<PRFMediaDTO> receiptDTOs,
  }) async {
    final member = _hiveService.retrieveMember()!;

    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );

    final PRFAllocationEntry updatedEntry;
    try {
      updatedEntry = await _allocationEntryService.update(
        id: allocationEntryUlid,
        data: PRFAllocationEntryDTO(
          accountingEventUlid: accountingEventUlid,
          expenseCategoryUlid: expenseCategoryUlid,
          memberUlid: member.ulid,
          entryType: entryType,
          chargeType: chargeType,
          charge: charge,
          unitCost: unitCost,
          quantity: quantity,
          narration: narration,
          confirmationMessage: confirmationMessage,
        ).toJson(),
        includes: defaultIncludes,
      );
      await dbService.persistEntity(updatedEntry);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
      return;
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
      return;
    }

    if (receiptDTOs.isEmpty) {
      return;
    }

    for (final receiptDTO in receiptDTOs) {
      await _mediaService.uploadFile(
        imageDTO: receiptDTO.copyWith(modelUlid: updatedEntry.ulid),
      );
    }
  }

  Future<void> addAllocationTokenEntry({
    required String accountingEventUlid,
    required PRFEntryType entryType,
    required int unitCost,
    required String narration,
    required String confirmationMessage,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.create,
      ),
    );

    try {
      final member = _hiveService.retrieveMember()!;
      final item = await _allocationEntryService.addToken(
        data: PRFAllocationTokenEntryDTO(
          accountingEventUlid: accountingEventUlid,
          memberUlid: member.ulid,
          entryType: entryType,
          unitCost: unitCost,
          narration: narration,
          confirmationMessage: confirmationMessage,
        ),
      );

      await dbService.persistEntity(item);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }

  Future<void> deleteAllocationEntry({
    required String allocationEntryUlid,
  }) {
    return delete(
      ulid: allocationEntryUlid,
      matchById: (item) => item.ulid == allocationEntryUlid,
    );
  }

  Future<void> deleteReceipt({
    required String allocationEntryUlid,
    required String mediaUuid,
  }) async {
    emit(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );

    try {
      await _allocationEntryService.deleteReceipt(
        allocationEntryUlid: allocationEntryUlid,
        mediaUuid: mediaUuid,
      );

      // Refresh the entry from the API and persist it — the DB stream
      // re-emits the updated list state.
      final entry = await _allocationEntryService.get(
        ulid: allocationEntryUlid,
        includes: defaultIncludes,
      );
      await dbService.persistEntity(entry);
    } on Failure catch (e) {
      emit(ResourceState.error(message: e.message, items: currentItems));
    } catch (e) {
      emit(ResourceState.error(message: e.toString(), items: currentItems));
    }
  }

  Future<void> refreshForAccountingEvent({
    required String accountingEventUlid,
  }) {
    return loadAll(
      includes: [
        'expenseCategory',
        'member',
        'accountingEvent',
        'accountingEvent.refunds',
        'accountingEvent.latestRefund',
        'receipts',
      ],
      filters: {'accounting_event_ulid': accountingEventUlid},
    );
  }

  Future<PRFAllocationEntry> fetchByUlid({
    required String allocationEntryUlid,
  }) {
    return _allocationEntryService.get(ulid: allocationEntryUlid);
  }
}
