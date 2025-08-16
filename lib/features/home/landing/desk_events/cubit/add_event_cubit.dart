import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_event_type.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_event_dto.dart';
import 'package:leadership/services/api/event_service.dart';

part 'add_event_state.dart';
part 'add_event_cubit.freezed.dart';

class AddEventCubit extends Cubit<AddEventState> {
  AddEventCubit({
    required EventService eventService,
  }) : super(const AddEventState.initial()) {
    _eventService = eventService;
  }

  late EventService _eventService;

  Future<void> addEvent({
    required String name,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required PRFResponsibleDesk responsibleDesk,
  }) async {
    emit(const AddEventState.loading());

    try {
      await _eventService.create(
        data: PRFEventDTO(
          name: name,
          description: description,
          startDate: startTime.toIso8601String().split('T')[0],
          startTime: startTime.toIso8601String().split('T')[1],
          endDate: endTime.toIso8601String().split('T')[0],
          endTime: endTime.toIso8601String().split('T')[1],
          responsibleDesk: responsibleDesk.apiKey,
          eventType: PRFEventType.leadership.apiKey,
        ).toJson(),
      );

      emit(const AddEventState.loaded());
    } on Failure catch (f) {
      emit(AddEventState.error(f.message));
    } catch (e) {
      emit(AddEventState.error(e.toString()));
    }
  }
}
