import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

abstract class MediaService {
  Future<PRFMedia?> uploadFile({required PRFMediaDTO imageDTO});
  Future<List<PRFMediaDTO>> getAssets(
    BuildContext context, {
    required String modelUlid,
    required PRFMediaModel model,
    required RequestType mediaType,
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
    required RequestType mediaType,
  });
}

class MediaServiceImpl implements MediaService {
  final _networkUtil = NetworkUtil();

  /// Request storage permission based on Android version
  /// For Android 13+: Request specific media permissions
  /// For Android 12 and below: Request READ_EXTERNAL_STORAGE
  Future<PermissionStatus> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      // Android 13+ (API 33+)
      if (androidInfo.version.sdkInt >= 33) {
        // Request all media permissions
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
        
        // Return granted if any permission is granted
        if (statuses.values.any((status) => status.isGranted)) {
          return PermissionStatus.granted;
        }
        return PermissionStatus.denied;
      } else {
        // Android 12 and below
        return Permission.storage.request();
      }
    }
    // For iOS, return granted (handled by Info.plist)
    return PermissionStatus.granted;
  }

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
    required RequestType mediaType,
    int count = 9,
  }) async {
    try {
      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          themeColor: Theme.of(context).colorScheme.primary,
          textDelegate: const EnglishAssetPickerTextDelegate(),
          requestType: mediaType,
          maxAssets: count,
        ),
      );

      final uploadAssets = <PRFMediaDTO>[];

      if (assets != null && assets.isNotEmpty) {
        for (final asset in assets) {
          final filePath = (await asset.file)?.path;
          if (filePath != null) {
            uploadAssets.add(
              PRFMediaDTO(
                path: filePath,
                model: model,
                modelUlid: modelUlid,
                name: Misc.getFileName(filePath),
              ),
            );
          }
        }
      }

      return uploadAssets;
    } catch (e) {
      Logger().e('Error selecting assets: $e');
      throw Failure(message: 'Failed to select media: $e');
    }
  }

  @override
  Future<List<PRFMediaDTO>> getAudioFiles({
    required String modelUlid,
    required PRFMediaModel model,
  }) async {
    try {
      // Request appropriate storage permission based on Android version
      final status = await _requestStoragePermission();
      if (!status.isGranted) {
        throw Failure(message: 'Storage permission denied');
      }

      final result = await FilePicker.platform
          .pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['mp3', 'aac', 'ogg', 'mp4', 'wav', 'flac'],
          )
          .catchError((dynamic error) {
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
      await FilePicker.platform.clearTemporaryFiles();
    }
  }

  @override
  Future<List<PRFMediaDTO>> getDocuments({
    required String modelUlid,
    required PRFMediaModel model,
  }) async {
    try {
      // Request appropriate storage permission based on Android version
      final status = await _requestStoragePermission();
      if (!status.isGranted) {
        throw Failure(message: 'Storage permission denied');
      }

      final result = await FilePicker.platform.pickFiles(
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
    required RequestType mediaType,
  }) async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Failure(message: 'Camera permission denied');
      }

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Failure(message: 'No cameras available');
      }

      // Initialize camera controller
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: mediaType == RequestType.video,
      );

      await controller.initialize();

      try {
        late XFile capturedFile;

        if (mediaType == RequestType.video) {
          // Start video recording
          await controller.startVideoRecording();

          capturedFile = await controller.stopVideoRecording();
        } else {
          // Capture image
          capturedFile = await controller.takePicture();
        }

        // Create app directory for storing captured media
        final appDir = await path_provider.getApplicationDocumentsDirectory();
        final mediaDir = Directory('${appDir.path}/captured_media');
        await mediaDir.create(recursive: true);

        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = mediaType == RequestType.video ? 'mp4' : 'jpg';
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
      } finally {
        await controller.dispose();
      }
    } catch (e) {
      Logger().e('Error capturing from camera: $e');
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: 'Failed to capture from camera: $e');
    }
  }
}
