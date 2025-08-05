import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/singletons.dart';

mixin TimezoneMixin {
  String get timezone => getIt<HiveService>().auth.timezone;
}
