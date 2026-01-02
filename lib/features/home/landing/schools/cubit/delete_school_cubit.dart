import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/school_service.dart';

part 'delete_school_state.dart';
part 'delete_school_cubit.freezed.dart';

class DeleteSchoolCubit extends Cubit<DeleteSchoolState> {
  DeleteSchoolCubit({
    required SchoolService schoolService,
  }) : super(const DeleteSchoolState.initial()) {
    _schoolService = schoolService;
  }

  late SchoolService _schoolService;

  Future<void> deleteSchool({required String ulid}) async {
    emit(const DeleteSchoolState.loading());
    try {
      await _schoolService.delete(ulid: ulid);
      emit(const DeleteSchoolState.loaded());
    } on Failure catch (e) {
      emit(DeleteSchoolState.error(e.message));
    } catch (e) {
      emit(DeleteSchoolState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const DeleteSchoolState.initial());
  }
}
