import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/models/remote/prf_contact_type_dto.dart';
import 'package:leadership/services/api/contact_type_service.dart';
import 'package:leadership/services/local_storage/hive/db/contact_type_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class ContactTypeCubit extends ResourceCubit<PRFContactType> {
  ContactTypeCubit({
    required ContactTypeService contactTypeService,
    required ContactTypeHiveDbService hiveDbService,
  }) : super(service: contactTypeService, dbService: hiveDbService);

  @override
  Future<List<PRFContactType>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> createContactType({required String name}) {
    return create(
      data: PRFContactTypeDTO(name: name).toJson(),
    );
  }

  Future<void> updateContactType({
    required String ulid,
    required String name,
  }) {
    return update(
      id: ulid,
      data: PRFContactTypeDTO(name: name).toJson(),
      matchById: (ct) => ct.ulid == ulid,
    );
  }

  Future<void> deleteContactType({required String ulid}) {
    return delete(ulid: ulid, matchById: (ct) => ct.ulid == ulid);
  }
}
