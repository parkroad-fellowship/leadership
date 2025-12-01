import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/media_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/_index.dart';

part 'change_profile_picture_state.dart';
part 'change_profile_picture_cubit.freezed.dart';

class ChangeProfilePictureCubit extends Cubit<ChangeProfilePictureState> {
  ChangeProfilePictureCubit({
    required MediaService mediaService,
    required HiveService hiveService,
  }) : super(const ChangeProfilePictureState.initial()) {
    _mediaService = mediaService;
    _hiveService = hiveService;
  }

  late MediaService _mediaService;
  late HiveService _hiveService;

  Future<void> changeProfilePicture({
    required BuildContext context,
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
  }) async {
    try {
      emit(const ChangeProfilePictureState.loading());
      final media = await _mediaService.pickMediaWithSource(
        context,
        modelUlid: modelUlid,
        model: model,
        mediaType: mediaType,
        count: 1,
      );

      if (media.isEmpty) {
        emit(const ChangeProfilePictureState.empty());
        return;
      }

      final profilePicture = await _mediaService.uploadFile(
        imageDTO: media.first,
      );

      final user = _hiveService.auth.retrieveProfile()!;
      final updatedUser = user.member!.copyWith(profilePicture: profilePicture);
      _hiveService.auth.persistProfile(user.copyWith(member: updatedUser));

      emit(const ChangeProfilePictureState.loaded());
    } on Failure catch (e) {
      emit(ChangeProfilePictureState.error(e.message));
    } catch (e) {
      emit(ChangeProfilePictureState.error(e.toString()));
    }
  }
}
