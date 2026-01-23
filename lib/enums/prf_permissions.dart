enum PRFPermissions {
  viewAnyCommitteeItem,
  createEvent,
  createRequisition,
  createRequisitionItem,
  createPaymentInstruction,
  deleteAllocationEntry,
  deleteRequisitionItem,
  viewAnySchools,
  manageExpenseCategories,
  ;

  String get name {
    switch (this) {
      case PRFPermissions.viewAnyCommitteeItem:
        return 'viewAny committee item';
      case PRFPermissions.createEvent:
        return 'create event';
      case PRFPermissions.createRequisition:
        return 'create requisition';
      case PRFPermissions.createRequisitionItem:
        return 'create requisition item';
      case PRFPermissions.createPaymentInstruction:
        return 'create payment instruction';
      case PRFPermissions.deleteAllocationEntry:
        return 'delete allocation entry';
      case PRFPermissions.deleteRequisitionItem:
        return 'delete requisition item';
      case PRFPermissions.viewAnySchools:
        return 'viewAny school';
      case PRFPermissions.manageExpenseCategories:
        return 'create event';
    }
  }
}
