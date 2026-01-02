import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/services/api/school_service.dart';

part 'create_school_state.dart';
part 'create_school_cubit.freezed.dart';

class CreateSchoolCubit extends Cubit<CreateSchoolState> {
  CreateSchoolCubit({
    required SchoolService schoolService,
  }) : super(const CreateSchoolState.initial()) {
    _schoolService = schoolService;
  }

  late SchoolService _schoolService;

  Future<void> createSchool({
    required String name,
    required int totalStudents,
    required PRFInstitutionType institutionType,
    required String address,
    required double latitude,
    required double longitude,
    String? description,
    String? directions,
  }) async {
    emit(const CreateSchoolState.loading());
    try {
      final school = await _schoolService.create(
        data: {
          'name': name,
          'total_students': totalStudents,
          'institution_type': institutionType.value,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'description': description,
          'directions': directions,
        },
      );
      emit(CreateSchoolState.loaded(school: school));
    } on Failure catch (e) {
      emit(CreateSchoolState.error(e.message));
    } catch (e) {
      emit(CreateSchoolState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const CreateSchoolState.initial());
  }
}
