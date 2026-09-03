import 'package:get_it/get_it.dart';
import 'package:leadership/services/media_service.dart';

class MediaModule {
  static void register(GetIt getIt) {
    getIt.registerLazySingleton<MediaService>(MediaServiceImpl.new);
  }
}
