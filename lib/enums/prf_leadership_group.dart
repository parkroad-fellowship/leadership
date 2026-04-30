import 'package:leadership/enums/prf_responsible_desk.dart';

enum PRFLeadershipGroup {
  executiveCommittee,
  campCommittee
  ;

  String get apiKey {
    return switch (this) {
      PRFLeadershipGroup.executiveCommittee => 'is_executive_committee_member',
      PRFLeadershipGroup.campCommittee => 'is_camp_committee_member',
    };
  }

  static List<PRFLeadershipGroup> fromResponsibleDesk(PRFResponsibleDesk desk) {
    return switch (desk) {
      PRFResponsibleDesk.chairperson => [],
      PRFResponsibleDesk.viceChairperson => [],
      PRFResponsibleDesk.organisingSecretary => [],
      PRFResponsibleDesk.missions => [],
      PRFResponsibleDesk.prayer => [],
      PRFResponsibleDesk.followUp => [
        campCommittee,
      ],
      PRFResponsibleDesk.music => [],
      PRFResponsibleDesk.treasurer => [],
    };
  }
}
