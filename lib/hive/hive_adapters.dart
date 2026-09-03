import 'package:hive_ce/hive.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/enums/prf_mission_role.dart';
import 'package:leadership/enums/prf_mission_status.dart';
import 'package:leadership/enums/prf_mission_subscription_status.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/enums/prf_soul_decision_type.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:leadership/models/remote/mission/prf_mission_type.dart';
import 'package:leadership/models/remote/mission/prf_soul.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_church.dart';
import 'package:leadership/models/remote/prf_class_group.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_gift.dart';
import 'package:leadership/models/remote/prf_group.dart';
import 'package:leadership/models/remote/prf_group_member.dart';
import 'package:leadership/models/remote/prf_marital_status.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_membership.dart';
import 'package:leadership/models/remote/prf_profession.dart';
import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/models/remote/prf_spiritual_year.dart';
import 'package:leadership/models/remote/prf_weather_forecast.dart';

@GenerateAdapters(
  [
    AdapterSpec<PRFUser>(),
    AdapterSpec<PRFInstitutionType>(),
    AdapterSpec<PRFResponsibleDesk>(),
    AdapterSpec<PRFMissionRole>(),
    AdapterSpec<PRFMissionStatus>(),
    AdapterSpec<PRFMissionSubscriptionStatus>(),
    AdapterSpec<PRFSoulDecisionType>(),
    AdapterSpec<PRFRole>(),
    AdapterSpec<PRFPermission>(),
    AdapterSpec<PRFMember>(),
    AdapterSpec<PRFGroupMember>(),
    AdapterSpec<PRFGroup>(),
    AdapterSpec<PRFMembership>(),
    AdapterSpec<PRFSpiritualYear>(),
    AdapterSpec<PRFMaritalStatus>(),
    AdapterSpec<PRFProfession>(),
    AdapterSpec<PRFChurch>(),
    AdapterSpec<PRFMedia>(),
    AdapterSpec<PRFClassGroupResponse>(),
    AdapterSpec<PRFClassGroup>(),
    AdapterSpec<PRFSoulResponse>(),
    AdapterSpec<PRFSoul>(),
    AdapterSpec<PRFMission>(),
    AdapterSpec<PRFMissionSubscription>(),
    AdapterSpec<PRFMissionType>(),
    AdapterSpec<PRFSchool>(),
    AdapterSpec<PRFSchoolTerm>(),
    AdapterSpec<PRFContact>(),
    AdapterSpec<PRFContactType>(),
    AdapterSpec<PRFWeatherForecast>(),
    AdapterSpec<PRFTemperature>(),
    AdapterSpec<PRFVisibility>(),
    AdapterSpec<PRFPrecipitationProbability>(),
    AdapterSpec<PRFHumidity>(),
    AdapterSpec<PRFAccountingEvent>(),
    AdapterSpec<PRFRefund>(),
    AdapterSpec<PRFExpenseCategoryResponse>(),
    AdapterSpec<PRFExpenseCategory>(),
    AdapterSpec<PRFMediaModel>(),
    AdapterSpec<PRFGift>(),
    AdapterSpec<PRFDepartment>(),
    AdapterSpec<PRFActiveStatus>(),
  ],
  reservedTypeIds: {4},
)
part 'hive_adapters.g.dart';
