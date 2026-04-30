import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/services/api/contact_type_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class ContactTypeCubit extends ResourceCubit<PRFContactType> {
  ContactTypeCubit({required ContactTypeService contactTypeService})
    : super(service: contactTypeService);

  Future<void> createContactType({required String name}) {
    return create(data: {'name': name});
  }

  Future<void> updateContactType({
    required String ulid,
    required String name,
  }) {
    return update(
      id: ulid,
      data: {'name': name},
      matchById: (ct) => ct.ulid == ulid,
    );
  }

  Future<void> deleteContactType({required String ulid}) {
    return delete(ulid: ulid, matchById: (ct) => ct.ulid == ulid);
  }
}
