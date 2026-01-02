import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/services/api/school_service.dart';

part 'get_schools_state.dart';
part 'get_schools_cubit.freezed.dart';

class GetSchoolsCubit extends Cubit<GetSchoolsState> {
  GetSchoolsCubit({
    required SchoolService schoolService,
  }) : super(const GetSchoolsState.initial()) {
    _schoolService = schoolService;
  }

  late SchoolService _schoolService;

  Future<void> getSchools({
    Map<String, dynamic>? filters,
    String? orderBy,
    String? orderDirection,
  }) async {
    emit(const GetSchoolsState.loading());
    try {
      final schools = await _schoolService.list(
        includes: ['schoolContacts.contactType'],
        filters: filters,
        orderBy: orderBy ?? 'created_at',
        orderDirection: orderDirection ?? 'desc',
      );
      emit(GetSchoolsState.loaded(schools: schools));
    } on Failure catch (e) {
      emit(GetSchoolsState.error(e.message));
    } catch (e) {
      emit(GetSchoolsState.error(e.toString()));
    }
  }
}
