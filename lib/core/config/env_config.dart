import 'dart:io';
import 'package:flutter/foundation.dart';

class EnvConfig {
  EnvConfig._();

  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    if (!kIsWeb && Platform.isAndroid) {
      // 127.0.0.1 connects to your PC through 'adb reverse tcp:5000 tcp:5000',
      // bypassing Wi-Fi AP client isolation and Windows Firewall.
      return 'http://127.0.0.1:5000/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  static const int connectionTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
