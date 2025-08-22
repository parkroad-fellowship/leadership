enum PRFLeadershipGroup {
  executiveCommittee;

  String get apiKey {
    return switch (this) {
      PRFLeadershipGroup.executiveCommittee => 'is_executive_committee_member',
    };
  }
}
