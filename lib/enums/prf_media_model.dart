enum PRFMediaModel {
  missionPhotos,
  missionFitChecks,
  missionSessionAudios,
  eventPhotos,
  memberProfilePictures,
  expenses;

  String get collection {
    switch (this) {
      case PRFMediaModel.missionPhotos:
        return 'mission-photos';
      case PRFMediaModel.missionFitChecks:
        return 'mission-fit-checks';
      case PRFMediaModel.missionSessionAudios:
        return 'session-audios';
      case PRFMediaModel.eventPhotos:
        return 'event-photos';
      case PRFMediaModel.memberProfilePictures:
        return 'profile-pictures';
      case PRFMediaModel.expenses:
        return 'receipts';
    }
  }
}
