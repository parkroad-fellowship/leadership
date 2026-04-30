enum PRFNotificationType {
  defaultPrompt(null),
  newRequisition('new_requisition'),
  requisitionApproved('requisition_approved'),
  requisitionRecalled('requisition_recalled'),
  requisitionRejected('requisition_rejected'),
  requisitionReviewRequested('requisition_review_requested'),
  ;

  const PRFNotificationType(this.typeKey);

  final String? typeKey;

  static PRFNotificationType fromType(String type) {
    return PRFNotificationType.values.firstWhere(
      (v) => v.typeKey == type,
      orElse: () => PRFNotificationType.defaultPrompt,
    );
  }
}
