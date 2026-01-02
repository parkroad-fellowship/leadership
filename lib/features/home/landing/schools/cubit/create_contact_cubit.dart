import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/services/api/school_contact_service.dart';

part 'create_contact_state.dart';
part 'create_contact_cubit.freezed.dart';

class CreateContactCubit extends Cubit<CreateContactState> {
  CreateContactCubit({
    required SchoolContactService schoolContactService,
  }) : super(const CreateContactState.initial()) {
    _schoolContactService = schoolContactService;
  }

  late SchoolContactService _schoolContactService;

  Future<void> createContact({
    required String name,
    required String phone,
    String? email,
    String? contactTypeUlid,
  }) async {
    emit(const CreateContactState.loading());
    try {
      final contact = await _schoolContactService.create(
        data: {
          'name': name,
          'phone': phone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (contactTypeUlid != null && contactTypeUlid.isNotEmpty)
            'contact_type_ulid': contactTypeUlid,
        },
      );
      emit(CreateContactState.loaded(contact: contact));
    } on Failure catch (e) {
      emit(CreateContactState.error(e.message));
    } catch (e) {
      emit(CreateContactState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const CreateContactState.initial());
  }
}
