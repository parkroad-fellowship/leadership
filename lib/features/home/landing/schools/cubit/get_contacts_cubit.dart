import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/services/api/school_contact_service.dart';

part 'get_contacts_state.dart';
part 'get_contacts_cubit.freezed.dart';

class GetContactsCubit extends Cubit<GetContactsState> {
  GetContactsCubit({required SchoolContactService schoolContactService})
    : super(const GetContactsState.initial()) {
    _schoolContactService = schoolContactService;
  }

  late SchoolContactService _schoolContactService;

  Future<void> getContactsForSchool(String schoolUlid) async {
    emit(const GetContactsState.loading());
    try {
      final contacts = await _schoolContactService.list(
        filters: {'school_ulid': schoolUlid},
        includes: ['contactType'],
      );
      emit(GetContactsState.loaded(contacts: contacts));
    } on Failure catch (e) {
      emit(GetContactsState.error(e.message));
    } catch (e) {
      emit(GetContactsState.error(e.toString()));
    }
  }
}
