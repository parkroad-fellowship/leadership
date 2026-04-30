import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/singletons.dart';

mixin CurrentMemberMixin {
  PRFMember get loggedInMember => getIt<HiveService>().retrieveMember()!;
}
