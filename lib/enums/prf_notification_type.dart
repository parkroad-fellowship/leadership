enum PRFNotificationType {
  defaultPrompt,
  newRequisition,
  requisitionApproved,
  requisitionRecalled,
  requisitionRejected,
  requisitionReviewRequested
  ;

  static PRFNotificationType fromType(String type) {
    switch (type) {
      case 'new_requisition':
        return PRFNotificationType.newRequisition;
      case 'requisition_approved':
        return PRFNotificationType.requisitionApproved;
      case 'requisition_recalled':
        return PRFNotificationType.requisitionRecalled;
      case 'requisition_rejected':
        return PRFNotificationType.requisitionRejected;
      case 'requisition_review_requested':
        return PRFNotificationType.requisitionReviewRequested;
      default:
        return PRFNotificationType.defaultPrompt;
    }
  }
}
