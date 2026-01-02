import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/services/api/contact_type_service.dart';

part 'update_contact_type_state.dart';
part 'update_contact_type_cubit.freezed.dart';

class UpdateContactTypeCubit extends Cubit<UpdateContactTypeState> {
  UpdateContactTypeCubit({
    required ContactTypeService contactTypeService,
  }) : super(const UpdateContactTypeState.initial()) {
    _contactTypeService = contactTypeService;
  }

  late ContactTypeService _contactTypeService;

  Future<void> updateContactType({
    required String ulid,
    required String name,
  }) async {
    emit(const UpdateContactTypeState.loading());
    try {
      final contactType = await _contactTypeService.update(
        id: ulid,
        data: {
          'name': name,
        },
      );
      emit(UpdateContactTypeState.loaded(contactType: contactType));
    } on Failure catch (e) {
      emit(UpdateContactTypeState.error(e.message));
    } catch (e) {
      emit(UpdateContactTypeState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const UpdateContactTypeState.initial());
  }
}
