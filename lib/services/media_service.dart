import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leadership/enums/media_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/utils/azure_blob_storage.dart';
import 'package:leadership/utils/constants.dart';
import 'package:leadership/utils/http/network.dart';
import 'package:leadership/utils/misc.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:prf_design/prf_design.dart';

abstract class MediaService {
  Future<PRFMedia?> uploadFile({required PRFMediaDTO imageDTO});
  Future<List<PRFMediaDTO>> getAssets(
    BuildContext context, {
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
    int count = 9,
  });
  Future<List<PRFMediaDTO>> pickMediaWithSource(
    BuildContext context, {
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
    int count = 9,
  });
  Future<List<PRFMediaDTO>> getAudioFiles({
    required String modelUlid,
    required PRFMediaModel model,
  });
  Future<List<PRFMediaDTO>> getDocuments({
    required String modelUlid,
    required PRFMediaModel model,
  });
  Future<PRFMediaDTO?> captureFromCamera(
    BuildContext context, {
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
  });
}

/// Plain-language message for picker failures in methods that have no
/// [BuildContext] to localise with. Never expose raw exception text.
const String _selectFailedMessage = "Couldn't add that file. Please try again.";

class MediaServiceImpl implements MediaService {
  final _networkUtil = NetworkUtil();
  final _picker = ImagePicker();

  @override
  Future<PRFMedia?> uploadFile({required PRFMediaDTO imageDTO}) async {
    final url = StringBuffer('/');
    Logger().d(imageDTO);

    switch (imageDTO.model) {
      case PRFMediaModel.memberProfilePictures:
        url.write('members');
      case PRFMediaModel.allocationEntryReceipts:
        url.write('allocation-entries');
    }

    url.write('/${imageDTO.modelUlid}/media');

    try {
      // Upload the actual file to Azure to have their servers handle the load
      final azureStorage = AzureStorage.parse(
        PRFLeadershipConfig.instance!.values.azureConnString,
      );

      await azureStorage.putBlob(
        'prf-media-upload/${Misc.getFileName(imageDTO.path)}',
        bodyBytes: File(imageDTO.path).readAsBytesSync(),
        contentType:
            mime.lookupMimeType(imageDTO.path) ?? 'application/octet-stream',
      );

      // Upload the reference to our server
      final res = await _networkUtil.post(
        url.toString(),
        body: json.encode({
          'media_file_storage_path': imageDTO.name,
          'collection': imageDTO.model.collection,
        }),
        apiVersion: 'v2',
      );

      return PRFMedia.fromJson(res['data'] as Map<String, dynamic>);
    } catch (e) {
      Logger().e(e.toString());
      return null;
    }
  }

  @override
  Future<List<PRFMediaDTO>> getAssets(
    BuildContext context, {
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
    int count = 9,
  }) async {
    try {
      // Use image_picker with multi_image for multiple selection
      // On Android 13+, this automatically uses the Photo Picker
      // without requiring permissions
      var files = <XFile>[];

      if (mediaType == MediaType.image) {
        if (count == 1) {
          final image = await _picker.pickImage(source: ImageSource.gallery);
          if (image != null) files = [image];
        } else {
          files = await _picker.pickMultiImage(limit: count);
        }
      } else if (mediaType == MediaType.video) {
        final video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video != null) files = [video];
      }

      final uploadAssets = <PRFMediaDTO>[];

      for (final file in files) {
        uploadAssets.add(
          PRFMediaDTO(
            path: file.path,
            model: model,
            modelUlid: modelUlid,
            name: Misc.getFileName(file.path),
          ),
        );
      }

      return uploadAssets;
    } catch (e) {
      Logger().e('Error selecting assets: $e');
      throw Failure(message: _selectFailedMessage);
    }
  }

  @override
  Future<List<PRFMediaDTO>> pickMediaWithSource(
    BuildContext context, {
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
    int count = 9,
  }) async {
    try {
      // Ask the user whether to use the camera or the gallery.
      final l10n = context.l10n;
      final isVideo = mediaType == MediaType.video;
      final choice = await showPRFMediaSourceSheet(
        context,
        labels: PRFMediaSourceLabels(
          title: isVideo ? l10n.mediaSourceTitleVideo : l10n.mediaSourceTitle,
          camera: l10n.mediaSourceCamera,
          cameraDescription: isVideo
              ? l10n.mediaSourceRecordVideo
              : l10n.mediaSourceTakePhoto,
          gallery: l10n.mediaSourceGallery,
          galleryDescription: count > 1
              ? l10n.mediaSourceChooseMany(count)
              : l10n.mediaSourceChooseOne,
        ),
      );

      final source = switch (choice) {
        PRFMediaSource.camera => ImageSource.camera,
        PRFMediaSource.gallery => ImageSource.gallery,
        PRFMediaSource.file || null => null,
      };

      if (source == null) {
        return [];
      }

      var files = <XFile>[];

      if (source == ImageSource.camera) {
        // Request camera permission
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          throw Failure(message: l10n.mediaCameraPermissionDenied);
        }

        XFile? capturedFile;
        if (mediaType == MediaType.video) {
          capturedFile = await _picker.pickVideo(source: ImageSource.camera);
        } else {
          capturedFile = await _picker.pickImage(source: ImageSource.camera);
        }

        if (capturedFile != null) {
          files = [capturedFile];
        }
      } else {
        // Gallery selection
        if (mediaType == MediaType.image) {
          if (count == 1) {
            final image = await _picker.pickImage(source: ImageSource.gallery);
            if (image != null) files = [image];
          } else {
            files = await _picker.pickMultiImage(limit: count);
          }
        } else if (mediaType == MediaType.video) {
          final video = await _picker.pickVideo(source: ImageSource.gallery);
          if (video != null) files = [video];
        }
      }

      final uploadAssets = <PRFMediaDTO>[];

      for (final file in files) {
        // Create app directory for storing media
        final appDir = await path_provider.getApplicationDocumentsDirectory();
        final mediaDir = Directory('${appDir.path}/selected_media');
        await mediaDir.create(recursive: true);

        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final originalFileName = Misc.getFileName(file.path);
        final extension = originalFileName.split('.').last;
        final fileName = 'media_$timestamp.$extension';
        final newPath = '${mediaDir.path}/$fileName';

        // Copy file to app directory
        final savedFile = await File(file.path).copy(newPath);

        uploadAssets.add(
          PRFMediaDTO(
            path: savedFile.path,
            model: model,
            modelUlid: modelUlid,
            name: fileName,
          ),
        );
      }

      return uploadAssets;
    } catch (e) {
      Logger().e('Error picking media with source: $e');
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: _selectFailedMessage);
    }
  }

  @override
  Future<List<PRFMediaDTO>> getAudioFiles({
    required String modelUlid,
    required PRFMediaModel model,
  }) async {
    // FilePicker uses SAF (Storage Access Framework)
    // which doesn't require permissions
    final filePaths =
        await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['mp3', 'aac', 'ogg', 'mp4', 'wav', 'flac'],
        ).catchError((dynamic error) {
          if (error is PlatformException && error.code == 'multiple_request') {
            throw Failure(
              message:
                  'A file picker is already open. Finish or close it, '
                  'then try again.',
            );
          }
          Logger().e('Error selecting audio files: $error');
          throw Failure(message: _selectFailedMessage);
        });

    final uploadAssets = <PRFMediaDTO>[];
    final appDir = await path_provider.getApplicationDocumentsDirectory();

    try {
      for (final filePath in filePaths) {
        if (filePath.path != null) {
          final fileName = StringFormatter.getFileName(filePath.path!);
          final mediaUploadsDir = '${appDir.path}/media_uploads';
          await Directory(mediaUploadsDir).create(recursive: true);
          final newPath = '$mediaUploadsDir/$fileName';

          final file = File(filePath.path!);
          await file.copy(newPath);

          uploadAssets.add(
            PRFMediaDTO(
              path: newPath,
              model: model,
              modelUlid: modelUlid,
              name: fileName,
            ),
          );
        }
      }
      return uploadAssets;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PRFMediaDTO>> getDocuments({
    required String modelUlid,
    required PRFMediaModel model,
  }) async {
    try {
      // FilePicker uses SAF (Storage Access Framework)
      // which doesn't require permissions
      final filePaths = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (filePaths.isNotEmpty) {
        final uploadAssets = <PRFMediaDTO>[];
        final appDir = await path_provider.getApplicationDocumentsDirectory();

        for (final filePath in filePaths) {
          final file = File(filePath.path!);
          final fileName = StringFormatter.getFileName(filePath.path!);
          final mediaUploadsDir = '${appDir.path}/media_uploads';
          await Directory(mediaUploadsDir).create(recursive: true);
          final newPath = '$mediaUploadsDir/$fileName';

          await file.copy(newPath);

          uploadAssets.add(
            PRFMediaDTO(
              path: newPath,
              model: model,
              modelUlid: modelUlid,
              name: fileName,
            ),
          );
        }
        return uploadAssets;
      }

      return [];
    } catch (e) {
      Logger().e('Error selecting documents: $e');
      throw Failure(message: _selectFailedMessage);
    }
  }

  @override
  Future<PRFMediaDTO?> captureFromCamera(
    BuildContext context, {
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
  }) async {
    final l10n = context.l10n;
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Failure(message: l10n.mediaCameraPermissionDenied);
      }

      // Use image_picker for camera capture - it handles permissions gracefully
      XFile? capturedFile;

      if (mediaType == MediaType.video) {
        capturedFile = await _picker.pickVideo(source: ImageSource.camera);
      } else {
        capturedFile = await _picker.pickImage(source: ImageSource.camera);
      }

      if (capturedFile == null) {
        return null;
      }

      // Create app directory for storing captured media
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final mediaDir = Directory('${appDir.path}/captured_media');
      await mediaDir.create(recursive: true);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = mediaType == MediaType.video ? 'mp4' : 'jpg';
      final fileName = 'captured_$timestamp.$extension';
      final newPath = '${mediaDir.path}/$fileName';

      // Move captured file to app directory
      final savedFile = await File(capturedFile.path).copy(newPath);

      return PRFMediaDTO(
        path: savedFile.path,
        model: model,
        modelUlid: modelUlid,
        name: fileName,
      );
    } catch (e) {
      Logger().e('Error capturing from camera: $e');
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: l10n.mediaCaptureFailed);
    }
  }
}
