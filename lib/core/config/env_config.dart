import 'dart:io';
import 'package:flutter/foundation.dart';

class EnvConfig {
  EnvConfig._();

  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  static const int connectionTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
