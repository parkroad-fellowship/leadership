import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/services/api/school_service.dart';

part 'update_school_state.dart';
part 'update_school_cubit.freezed.dart';

class UpdateSchoolCubit extends Cubit<UpdateSchoolState> {
  UpdateSchoolCubit({
    required SchoolService schoolService,
  }) : super(const UpdateSchoolState.initial()) {
    _schoolService = schoolService;
  }

  late SchoolService _schoolService;

  Future<void> updateSchool({
    required String ulid,
    required String name,
    required int totalStudents,
    required PRFInstitutionType institutionType,
    required String address,
    required double latitude,
    required double longitude,
    String? description,
    String? directions,
  }) async {
    emit(const UpdateSchoolState.loading());
    try {
      final school = await _schoolService.update(
        id: ulid,
        data: {
          'name': name,
          'total_students': totalStudents,
          'institution_type': institutionType.value,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'description': ?description,
          'directions': ?directions,
        },
      );
      emit(UpdateSchoolState.loaded(school: school));
    } on Failure catch (e) {
      emit(UpdateSchoolState.error(e.message));
    } catch (e) {
      emit(UpdateSchoolState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const UpdateSchoolState.initial());
  }
}
