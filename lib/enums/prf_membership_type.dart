enum PrfMembershipType {
  friend,
  yearlyMember,
  lifetimeMember;

  String get name {
    switch (this) {
      case PrfMembershipType.friend:
        return 'Friend';
      case PrfMembershipType.yearlyMember:
        return 'Yearly Member';
      case PrfMembershipType.lifetimeMember:
        return 'Lifetime Member';
    }
  }

  static PrfMembershipType fromIndex(int index) {
    switch (index) {
      case 1:
        return PrfMembershipType.friend;
      case 2:
        return PrfMembershipType.yearlyMember;
      case 3:
        return PrfMembershipType.lifetimeMember;
      default:
        return PrfMembershipType.friend;
    }
  }
}
