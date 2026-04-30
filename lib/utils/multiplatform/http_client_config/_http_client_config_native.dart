import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void configureCertificateBypass(Dio dio) {
  if (dio.httpClientAdapter is! IOHttpClientAdapter) return;
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
      HttpClient()..badCertificateCallback = (_, _, _) => true;
}

Future<bool> checkInternetConnectivity() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
