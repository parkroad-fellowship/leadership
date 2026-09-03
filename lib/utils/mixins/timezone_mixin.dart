import 'package:leadership/di/di_container.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

mixin TimezoneMixin {
  String get timezone => getIt<HiveService>().auth.timezone;
}
