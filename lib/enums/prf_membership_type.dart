enum PRFMembershipType {
  friend(1, 'Friend'),
  yearlyMember(2, 'Yearly Member'),
  lifetimeMember(3, 'Lifetime Member'),
  ;

  const PRFMembershipType(this.apiKey, this._label);

  final int apiKey;
  final String _label;

  String get name => _label;

  static PRFMembershipType fromIndex(int index) {
    return PRFMembershipType.values.firstWhere(
      (v) => v.apiKey == index,
      orElse: () => PRFMembershipType.friend,
    );
  }
}
