import 'package:leadership/di/di_container.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

mixin CurrentMemberMixin {
  PRFMember get loggedInMember => getIt<HiveService>().retrieveMember()!;
}
