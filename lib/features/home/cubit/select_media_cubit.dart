import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/media_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/services/_index.dart';

part 'select_media_state.dart';
part 'select_media_cubit.freezed.dart';

class SelectMediaCubit extends Cubit<SelectMediaState> {
  SelectMediaCubit({
    required MediaService mediaService,
  }) : super(const SelectMediaState.initial()) {
    _mediaService = mediaService;
  }

  late MediaService _mediaService;

  Future<void> selectMedia({
    required BuildContext context,
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
    List<PRFMediaDTO> previousMedia = const [],
  }) async {
    try {
      emit(const SelectMediaState.loading());

      final media = await _mediaService.getAssets(
        context,
        modelUlid: modelUlid,
        model: model,
        mediaType: mediaType,
      );

      final items = [...previousMedia, ...media];

      if (items.isEmpty) {
        emit(const SelectMediaState.empty());
      } else {
        emit(SelectMediaState.loaded(media: items));
      }
    } on Failure catch (f) {
      emit(SelectMediaState.error(f.message));
    } catch (e) {
      emit(SelectMediaState.error(e.toString()));
    }
  }

  Future<void> selectMediaWithSource({
    required BuildContext context,
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
    List<PRFMediaDTO> previousMedia = const [],
  }) async {
    try {
      emit(const SelectMediaState.loading());

      final media = await _mediaService.pickMediaWithSource(
        context,
        modelUlid: modelUlid,
        model: model,
        mediaType: mediaType,
      );

      final items = [...previousMedia, ...media];

      if (items.isEmpty) {
        emit(const SelectMediaState.empty());
      } else {
        emit(SelectMediaState.loaded(media: items));
      }
    } on Failure catch (f) {
      emit(SelectMediaState.error(f.message));
    } catch (e) {
      emit(SelectMediaState.error(e.toString()));
    }
  }

  Future<void> captureFromCamera({
    required BuildContext context,
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
    List<PRFMediaDTO> previousMedia = const [],
  }) async {
    try {
      emit(const SelectMediaState.loading());

      final media = await _mediaService.captureFromCamera(
        context,
        modelUlid: modelUlid,
        model: model,
        mediaType: mediaType,
      );

      if (media != null) {
        final items = [...previousMedia, media];
        emit(SelectMediaState.loaded(media: items));
      } else {
        // User cancelled or no media captured
        emit(SelectMediaState.loaded(media: previousMedia));
      }
    } on Failure catch (f) {
      emit(SelectMediaState.error(f.message));
    } catch (e) {
      emit(SelectMediaState.error(e.toString()));
    }
  }

  Future<void> selectDocuments({
    required String modelUlid,
    required PRFMediaModel model,
    List<PRFMediaDTO> previousMedia = const [],
  }) async {
    try {
      emit(const SelectMediaState.loading());

      final media = await _mediaService.getDocuments(
        modelUlid: modelUlid,
        model: model,
      );

      final items = [...previousMedia, ...media];

      if (items.isEmpty) {
        emit(const SelectMediaState.empty());
      } else {
        emit(SelectMediaState.loaded(media: items));
      }
    } on Failure catch (f) {
      emit(SelectMediaState.error(f.message));
    } catch (e) {
      emit(SelectMediaState.error(e.toString()));
    }
  }

  void clearMedia() {
    emit(const SelectMediaState.loaded(media: []));
  }
}
