import 'package:dio/dio.dart';

void configureCertificateBypass(Dio dio) {
  // No certificate bypass needed on web
}

Future<bool> checkInternetConnectivity() async {
  // On web, assume connected (browser handles connectivity)
  return true;
}
