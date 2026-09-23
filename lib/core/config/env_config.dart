import 'dart:io';
import 'package:flutter/foundation.dart';

class EnvConfig {
  EnvConfig._();

  static String get baseUrl {
    // 192.168.1.40 works on both physical Android phones and Android emulators on the same Wi-Fi
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.1.40:5000/api/v1';
    }
    return 'http://192.168.1.40:5000/api/v1';
  }

  static const int connectionTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
