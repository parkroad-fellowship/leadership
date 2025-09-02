import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/services/media_service.dart';
import 'package:logger/logger.dart';

part 'upload_media_state.dart';
part 'upload_media_cubit.freezed.dart';

class UploadMediaCubit extends Cubit<UploadMediaState> {
  UploadMediaCubit({
    required MediaService mediaService,
  }) : super(const UploadMediaState.initial()) {
    _mediaService = mediaService;
  }

  late MediaService _mediaService;

  Future<void> uploadMedia({
    required List<PRFMediaDTO> imageDTOs,
  }) async {
    emit(const UploadMediaState.loading());
    try {
      Logger().d(imageDTOs);
      for (final imageDTO in imageDTOs) {
        await _mediaService.uploadFile(imageDTO: imageDTO);
      }
      emit(const UploadMediaState.loaded());
    } on Failure catch (e) {
      emit(UploadMediaState.error(e.message));
    } catch (e) {
      emit(UploadMediaState.error(e.toString()));
    }
  }
}
