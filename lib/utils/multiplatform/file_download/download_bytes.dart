import 'dart:typed_data';

import 'package:leadership/utils/multiplatform/file_download/download_bytes_stub.dart'
    if (dart.library.html) 'download_bytes_web.dart'
    as impl;

void downloadBytes({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) {
  impl.downloadBytes(bytes: bytes, fileName: fileName, mimeType: mimeType);
}
