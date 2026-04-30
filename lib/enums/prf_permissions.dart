enum PRFPermissions {
  // Users
  viewAnyUser('viewAny', 'user'),
  createUser('create', 'user'),
  editUser('edit', 'user'),
  deleteUser('delete', 'user'),

  // Members
  viewAnyMember('viewAny', 'member'),
  createMember('create', 'member'),
  editMember('edit', 'member'),
  deleteMember('delete', 'member'),

  // Missions
  viewAnyMission('viewAny', 'mission'),
  createMission('create', 'mission'),
  editMission('edit', 'mission'),
  deleteMission('delete', 'mission'),

  // Mission types
  viewAnyMissionType('viewAny', 'mission type'),
  createMissionType('create', 'mission type'),
  editMissionType('edit', 'mission type'),
  deleteMissionType('delete', 'mission type'),

  // Mission subscriptions
  viewAnyMissionSubscription('viewAny', 'mission subscription'),
  createMissionSubscription('create', 'mission subscription'),
  editMissionSubscription('edit', 'mission subscription'),
  deleteMissionSubscription('delete', 'mission subscription'),

  // Mission sessions
  viewAnyMissionSession('viewAny', 'mission session'),
  createMissionSession('create', 'mission session'),
  editMissionSession('edit', 'mission session'),
  deleteMissionSession('delete', 'mission session'),

  // Mission questions
  viewAnyMissionQuestion('viewAny', 'mission question'),
  createMissionQuestion('create', 'mission question'),
  editMissionQuestion('edit', 'mission question'),
  deleteMissionQuestion('delete', 'mission question'),

  // Mission ground suggestions
  viewAnyMissionGroundSuggestion('viewAny', 'mission ground suggestion'),
  createMissionGroundSuggestion('create', 'mission ground suggestion'),
  editMissionGroundSuggestion('edit', 'mission ground suggestion'),
  deleteMissionGroundSuggestion('delete', 'mission ground suggestion'),

  // Mission offline members
  viewAnyMissionOfflineMember('viewAny', 'mission offline member'),
  createMissionOfflineMember('create', 'mission offline member'),
  editMissionOfflineMember('edit', 'mission offline member'),
  deleteMissionOfflineMember('delete', 'mission offline member'),

  // Debrief notes
  viewAnyDebriefNote('viewAny', 'debrief note'),
  createDebriefNote('create', 'debrief note'),
  editDebriefNote('edit', 'debrief note'),
  deleteDebriefNote('delete', 'debrief note'),

  // Souls
  viewAnySoul('viewAny', 'soul'),
  createSoul('create', 'soul'),
  editSoul('edit', 'soul'),
  deleteSoul('delete', 'soul'),

  // Schools
  viewAnySchool('viewAny', 'school'),
  createSchool('create', 'school'),
  editSchool('edit', 'school'),
  deleteSchool('delete', 'school'),

  // School terms
  viewAnySchoolTerm('viewAny', 'school term'),
  createSchoolTerm('create', 'school term'),
  editSchoolTerm('edit', 'school term'),
  deleteSchoolTerm('delete', 'school term'),

  // School contacts
  viewAnySchoolContact('viewAny', 'school contact'),
  createSchoolContact('create', 'school contact'),
  editSchoolContact('edit', 'school contact'),
  deleteSchoolContact('delete', 'school contact'),

  // Events
  viewAnyEvent('viewAny', 'event'),
  createEvent('create', 'event'),
  editEvent('edit', 'event'),
  deleteEvent('delete', 'event'),

  // Committee items
  viewAnyCommitteeItem('viewAny', 'committee item'),

  // Requisitions
  viewAnyRequisition('viewAny', 'requisition'),
  createRequisition('create', 'requisition'),
  editRequisition('edit', 'requisition'),
  deleteRequisition('delete', 'requisition'),
  approveRequisition('approve', 'requisition'),
  recallRequisition('recall', 'requisition'),
  rejectRequisition('reject', 'requisition'),

  // Requisition items
  viewAnyRequisitionItem('viewAny', 'requisition item'),
  createRequisitionItem('create', 'requisition item'),
  editRequisitionItem('edit', 'requisition item'),
  deleteRequisitionItem('delete', 'requisition item'),

  // Payment instructions
  viewAnyPaymentInstruction('viewAny', 'payment instruction'),
  createPaymentInstruction('create', 'payment instruction'),
  editPaymentInstruction('edit', 'payment instruction'),
  deletePaymentInstruction('delete', 'payment instruction'),

  // Allocation entries
  viewAnyAllocationEntry('viewAny', 'allocation entry'),
  createAllocationEntry('create', 'allocation entry'),
  editAllocationEntry('edit', 'allocation entry'),
  deleteAllocationEntry('delete', 'allocation entry'),

  // Accounting events
  viewAnyAccountingEvent('viewAny', 'accounting event'),
  createAccountingEvent('create', 'accounting event'),
  editAccountingEvent('edit', 'accounting event'),
  deleteAccountingEvent('delete', 'accounting event'),

  // Churches
  viewAnyChurch('viewAny', 'church'),
  createChurch('create', 'church'),
  editChurch('edit', 'church'),
  deleteChurch('delete', 'church'),

  // Departments
  viewAnyDepartment('viewAny', 'department'),
  createDepartment('create', 'department'),
  editDepartment('edit', 'department'),
  deleteDepartment('delete', 'department'),

  // Gifts
  viewAnyGift('viewAny', 'gift'),
  createGift('create', 'gift'),
  editGift('edit', 'gift'),
  deleteGift('delete', 'gift'),

  // Professions
  viewAnyProfession('viewAny', 'profession'),
  createProfession('create', 'profession'),
  editProfession('edit', 'profession'),
  deleteProfession('delete', 'profession'),

  // Marital statuses
  viewAnyMaritalStatus('viewAny', 'marital status'),
  createMaritalStatus('create', 'marital status'),
  editMaritalStatus('edit', 'marital status'),
  deleteMaritalStatus('delete', 'marital status'),

  // Memberships
  viewAnyMembership('viewAny', 'membership'),
  createMembership('create', 'membership'),
  editMembership('edit', 'membership'),
  deleteMembership('delete', 'membership'),

  // Expenses
  viewAnyExpense('viewAny', 'expense'),
  createExpense('create', 'expense'),
  editExpense('edit', 'expense'),
  deleteExpense('delete', 'expense'),

  // Announcements
  viewAnyAnnouncement('viewAny', 'announcement'),
  createAnnouncement('create', 'announcement'),
  editAnnouncement('edit', 'announcement'),
  deleteAnnouncement('delete', 'announcement'),
  ;

  const PRFPermissions(this.action, this.resource);

  final String action;
  final String resource;

  /// The API permission key, e.g. 'create mission'
  String get key => '$action $resource';
}
