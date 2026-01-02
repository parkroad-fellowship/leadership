import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/services/api/contact_type_service.dart';

part 'create_contact_type_state.dart';
part 'create_contact_type_cubit.freezed.dart';

class CreateContactTypeCubit extends Cubit<CreateContactTypeState> {
  CreateContactTypeCubit({
    required ContactTypeService contactTypeService,
  }) : super(const CreateContactTypeState.initial()) {
    _contactTypeService = contactTypeService;
  }

  late ContactTypeService _contactTypeService;

  Future<void> createContactType({
    required String name,
  }) async {
    emit(const CreateContactTypeState.loading());
    try {
      final contactType = await _contactTypeService.create(
        data: {
          'name': name,
        },
      );
      emit(CreateContactTypeState.loaded(contactType: contactType));
    } on Failure catch (e) {
      emit(CreateContactTypeState.error(e.message));
    } catch (e) {
      emit(CreateContactTypeState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const CreateContactTypeState.initial());
  }
}
