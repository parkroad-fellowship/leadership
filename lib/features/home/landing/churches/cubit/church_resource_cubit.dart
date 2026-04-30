import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_church.dart';
import 'package:leadership/services/api/church_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class ChurchResourceCubit extends ResourceCubit<PRFChurch> {
  ChurchResourceCubit({required ChurchService churchService})
    : super(service: churchService);

  Future<void> createChurch({required String name}) {
    return create(data: {'name': name});
  }

  Future<void> updateChurch({
    required String ulid,
    String? name,
    PRFActiveStatus? isActive,
  }) {
    return update(
      id: ulid,
      data: {
        'name': ?name,
        if (isActive != null) 'is_active': isActive.apiKey,
      },
      matchById: (c) => c.ulid == ulid,
    );
  }

  Future<void> deleteChurch({required String ulid}) {
    return delete(ulid: ulid, matchById: (c) => c.ulid == ulid);
  }
}
