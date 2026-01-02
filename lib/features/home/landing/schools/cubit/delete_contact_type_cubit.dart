import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/contact_type_service.dart';

part 'delete_contact_type_state.dart';
part 'delete_contact_type_cubit.freezed.dart';

class DeleteContactTypeCubit extends Cubit<DeleteContactTypeState> {
  DeleteContactTypeCubit({
    required ContactTypeService contactTypeService,
  }) : super(const DeleteContactTypeState.initial()) {
    _contactTypeService = contactTypeService;
  }

  late ContactTypeService _contactTypeService;

  Future<void> deleteContactType({
    required String ulid,
  }) async {
    emit(const DeleteContactTypeState.loading());
    try {
      await _contactTypeService.delete(ulid: ulid);
      emit(const DeleteContactTypeState.loaded());
    } on Failure catch (e) {
      emit(DeleteContactTypeState.error(e.message));
    } catch (e) {
      emit(DeleteContactTypeState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const DeleteContactTypeState.initial());
  }
}
