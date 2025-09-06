enum PRFPermissions {
  viewAnyCommitteeItem,
  createEvent;

  String get name {
    switch (this) {
      case PRFPermissions.viewAnyCommitteeItem:
        return 'viewAny committee item';
      case PRFPermissions.createEvent:
        return 'create event';
    }
  }
}
