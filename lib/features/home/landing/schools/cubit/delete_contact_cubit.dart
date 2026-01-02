import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/school_contact_service.dart';

part 'delete_contact_state.dart';
part 'delete_contact_cubit.freezed.dart';

class DeleteContactCubit extends Cubit<DeleteContactState> {
  DeleteContactCubit({
    required SchoolContactService schoolContactService,
  }) : super(const DeleteContactState.initial()) {
    _schoolContactService = schoolContactService;
  }

  late SchoolContactService _schoolContactService;

  Future<void> deleteContact({required String ulid}) async {
    emit(const DeleteContactState.loading());
    try {
      await _schoolContactService.delete(ulid: ulid);
      emit(const DeleteContactState.loaded());
    } on Failure catch (e) {
      emit(DeleteContactState.error(e.message));
    } catch (e) {
      emit(DeleteContactState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const DeleteContactState.initial());
  }
}
