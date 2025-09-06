enum PRFPermissions {
  viewAnyCommitteeItem;

  String get name {
    switch (this) {
      case PRFPermissions.viewAnyCommitteeItem:
        return 'viewAny committee item';
    }
  }
}
