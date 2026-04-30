import 'dart:typed_data';

void downloadBytes({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) {
  // No-op on non-web platforms.
}
