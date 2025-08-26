enum PRFMediaModel {
  memberProfilePictures,
  allocationEntryReceipts;

  String get collection {
    switch (this) {
      case memberProfilePictures:
        return 'profile-pictures';
      case PRFMediaModel.allocationEntryReceipts:
        return 'allocation-entry-receipts';
    }
  }
}
