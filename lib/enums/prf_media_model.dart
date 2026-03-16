enum PRFMediaModel {
  memberProfilePictures('profile-pictures'),
  allocationEntryReceipts('allocation-entry-receipts'),
  ;

  const PRFMediaModel(this.collection);

  final String collection;
}
