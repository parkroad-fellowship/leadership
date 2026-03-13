enum PRFPermissions {
  viewAnyCommitteeItem,
  createEvent,
  viewAnyMission,
  createMission,
  updateMission,
  deleteMission,
  approveMission,
  rejectMission,
  cancelMission,
  completeMission,
  notifySchoolOfMission,
  requestSchoolFeedback,
  notifyMissionWhatsappGroup,
  generateMissionSummary,
  uploadMissionMediaToDrive,
  manageMissionSubscription,
  manageMissionSession,
  manageMissionQuestion,
  manageMissionDebrief,
  manageMissionSoul,
  manageMissionGroundSuggestion,
  createRequisition,
  createRequisitionItem,
  createPaymentInstruction,
  deleteAllocationEntry,
  deleteRequisitionItem,
  viewAnySchools
  ;

  String get name {
    switch (this) {
      case PRFPermissions.viewAnyCommitteeItem:
        return 'viewAny committee item';
      case PRFPermissions.createEvent:
        return 'create event';
      case PRFPermissions.viewAnyMission:
        return 'viewAny mission';
      case PRFPermissions.createMission:
        return 'create mission';
      case PRFPermissions.updateMission:
        return 'update mission';
      case PRFPermissions.deleteMission:
        return 'delete mission';
      case PRFPermissions.approveMission:
        return 'approve mission';
      case PRFPermissions.rejectMission:
        return 'reject mission';
      case PRFPermissions.cancelMission:
        return 'cancel mission';
      case PRFPermissions.completeMission:
        return 'complete mission';
      case PRFPermissions.notifySchoolOfMission:
        return 'notify school of mission';
      case PRFPermissions.requestSchoolFeedback:
        return 'request school feedback';
      case PRFPermissions.notifyMissionWhatsappGroup:
        return 'notify mission whatsapp group';
      case PRFPermissions.generateMissionSummary:
        return 'generate mission summary';
      case PRFPermissions.uploadMissionMediaToDrive:
        return 'upload mission media to drive';
      case PRFPermissions.manageMissionSubscription:
        return 'manage mission subscription';
      case PRFPermissions.manageMissionSession:
        return 'manage mission session';
      case PRFPermissions.manageMissionQuestion:
        return 'manage mission question';
      case PRFPermissions.manageMissionDebrief:
        return 'manage mission debrief';
      case PRFPermissions.manageMissionSoul:
        return 'manage mission soul';
      case PRFPermissions.manageMissionGroundSuggestion:
        return 'manage mission ground suggestion';
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
    }
  }
}
