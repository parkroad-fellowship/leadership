import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/services/api/contact_type_service.dart';

part 'get_contact_types_state.dart';
part 'get_contact_types_cubit.freezed.dart';

class GetContactTypesCubit extends Cubit<GetContactTypesState> {
  GetContactTypesCubit({
    required ContactTypeService contactTypeService,
  }) : super(const GetContactTypesState.initial()) {
    _contactTypeService = contactTypeService;
  }

  late ContactTypeService _contactTypeService;

  Future<void> getContactTypes() async {
    emit(const GetContactTypesState.loading());
    try {
      final contactTypes = await _contactTypeService.list();
      emit(GetContactTypesState.loaded(contactTypes: contactTypes));
    } on Failure catch (e) {
      emit(GetContactTypesState.error(e.message));
    } catch (e) {
      emit(GetContactTypesState.error(e.toString()));
    }
  }
}
