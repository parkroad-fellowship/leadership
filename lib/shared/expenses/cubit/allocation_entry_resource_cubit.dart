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
import 'package:logger/logger.dart';

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
  }) {
    return dbService.filterBy(
      (entry) => [
        filters?['accounting_event_ulid'] == null ||
            entry.accountingEvent?.ulid == filters?['accounting_event_ulid'],
        filters?['expense_category_ulid'] == null ||
            entry.expenseCategory?.ulid == filters?['expense_category_ulid'],
      ],
    );
  }

  @override
  List<String> get defaultIncludes => ['accountingEvent', 'expenseCategory'];

  /// Everything an expense row renders. Single-entry refetches use it too so
  /// a persisted row never loses its member or receipts.
  static const _rowIncludes = [
    'accountingEvent',
    'expenseCategory',
    'member',
    'receipts',
  ];

  /// Receipts upload after the entry is saved, so the saved row has none.
  /// Refetch it once they are up so the new receipts reach Hive (and the
  /// list) without waiting for the freshness window.
  Future<void> _refetchEntry(String ulid) async {
    try {
      final entry = await _allocationEntryService.get(
        ulid: ulid,
        includes: _rowIncludes,
      );
      await dbService.persistEntity(entry);
    } catch (e, s) {
      Logger().e('Error refetching expense entry', error: e, stackTrace: s);
    }
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
    await _refetchEntry(createdEntry.ulid);
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
    await _refetchEntry(updatedEntry.ulid);
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

  Future<void> deleteAllocationEntry({required String allocationEntryUlid}) {
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
        includes: _rowIncludes,
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
    bool force = false,
  }) {
    // The event's refunds come from `AccountingEventCubit` once per screen
    // instead of being embedded in every row. The plain `accountingEvent`
    // stays: [loadCachedList] scopes Hive rows by its ulid and editing an
    // expense reads it (the API has no `accounting_event_ulid` scalar).
    return loadAll(
      includes: _rowIncludes,
      filters: {'accounting_event_ulid': accountingEventUlid},
      force: force,
    );
  }

  Future<PRFAllocationEntry> fetchByUlid({
    required String allocationEntryUlid,
  }) {
    return _allocationEntryService.get(ulid: allocationEntryUlid);
  }
}
