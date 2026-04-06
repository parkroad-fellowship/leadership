import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leadership/enums/media_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

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
      throw Failure(message: 'Failed to select media: $e');
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
      // Show bottom sheet to let user choose between camera and gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          final theme = Theme.of(context);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Choose Source',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: const Text('Camera'),
                    subtitle: Text(
                      mediaType == MediaType.video
                          ? 'Record a video'
                          : 'Take a photo',
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.photo_library_outlined,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    title: const Text('Gallery'),
                    subtitle: Text(
                      count > 1
                          ? 'Select up to $count items'
                          : 'Choose from your library',
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );

      if (source == null) {
        return [];
      }

      var files = <XFile>[];

      if (source == ImageSource.camera) {
        // Request camera permission
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          throw Failure(message: 'Camera permission denied');
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
      throw Failure(message: 'Failed to select media: $e');
    }
  }

  @override
  Future<List<PRFMediaDTO>> getAudioFiles({
    required String modelUlid,
    required PRFMediaModel model,
  }) async {
    try {
      // FilePicker uses SAF (Storage Access Framework)
      // which doesn't require permissions
      final result =
          await FilePicker.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['mp3', 'aac', 'ogg', 'mp4', 'wav', 'flac'],
          ).catchError((dynamic error) {
            if (error is PlatformException &&
                error.code == 'multiple_request') {
              throw Failure(message: 'Another file selection is in progress');
            }
            throw Failure(message: error.toString());
          });

      if (result != null) {
        final filePaths = result.paths;
        final uploadAssets = <PRFMediaDTO>[];
        final appDir = await path_provider.getApplicationDocumentsDirectory();

        try {
          for (final filePath in filePaths) {
            if (filePath != null) {
              final file = File(filePath);
              final fileName = Misc.getFileName(filePath);
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
          }
          return uploadAssets;
        } catch (e) {
          rethrow;
        }
      }

      return [];
    } catch (e) {
      rethrow;
    } finally {
      await FilePicker.clearTemporaryFiles();
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
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.paths.isNotEmpty) {
        final filePaths = result.paths;
        final uploadAssets = <PRFMediaDTO>[];
        final appDir = await path_provider.getApplicationDocumentsDirectory();

        for (final filePath in filePaths) {
          if (filePath != null) {
            final file = File(filePath);
            final fileName = Misc.getFileName(filePath);
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
        }
        return uploadAssets;
      }

      return [];
    } catch (e) {
      Logger().e('Error selecting documents: $e');
      throw Failure(message: 'Failed to select PDF files: $e');
    }
  }

  @override
  Future<PRFMediaDTO?> captureFromCamera(
    BuildContext context, {
    required String modelUlid,
    required PRFMediaModel model,
    required MediaType mediaType,
  }) async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Failure(message: 'Camera permission denied');
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
      throw Failure(message: 'Failed to capture from camera: $e');
    }
  }
}
