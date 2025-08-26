import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/services/_index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
    required RequestType mediaType,
    List<PRFMediaDTO> previousMedia = const [],
  }) async {
    final media = await _mediaService.getAssets(
      context,
      modelUlid: modelUlid,
      model: model,
      mediaType: mediaType,
    );

    final items = [...previousMedia, ...media];

    if (items.isEmpty) {
      emit(const SelectMediaState.empty());
    }

    emit(SelectMediaState.loaded(media: items));
  }

  void clearMedia() {
    emit(const SelectMediaState.loaded(media: []));
  }
}
