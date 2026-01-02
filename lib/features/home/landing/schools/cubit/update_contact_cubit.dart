import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/services/api/school_contact_service.dart';

part 'update_contact_state.dart';
part 'update_contact_cubit.freezed.dart';

class UpdateContactCubit extends Cubit<UpdateContactState> {
  UpdateContactCubit({
    required SchoolContactService schoolContactService,
  }) : super(const UpdateContactState.initial()) {
    _schoolContactService = schoolContactService;
  }

  late SchoolContactService _schoolContactService;

  Future<void> updateContact({
    required String ulid,
    required String name,
    required String phone,
    String? email,
    String? contactTypeUlid,
  }) async {
    emit(const UpdateContactState.loading());
    try {
      final contact = await _schoolContactService.update(
        id: ulid,
        data: {
          'name': name,
          'phone': phone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (contactTypeUlid != null && contactTypeUlid.isNotEmpty)
            'contact_type_ulid': contactTypeUlid,
        },
      );
      emit(UpdateContactState.loaded(contact: contact));
    } on Failure catch (e) {
      emit(UpdateContactState.error(e.message));
    } catch (e) {
      emit(UpdateContactState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const UpdateContactState.initial());
  }
}
