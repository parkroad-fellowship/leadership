import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_gift.dart';
import 'package:leadership/services/api/gift_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class GiftResourceCubit extends ResourceCubit<PRFGift> {
  GiftResourceCubit({required GiftService giftService})
    : super(service: giftService);

  Future<void> createGift({required String name}) {
    return create(data: {'name': name});
  }

  Future<void> updateGift({
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
      matchById: (g) => g.ulid == ulid,
    );
  }

  Future<void> deleteGift({required String ulid}) {
    return delete(ulid: ulid, matchById: (g) => g.ulid == ulid);
  }
}
