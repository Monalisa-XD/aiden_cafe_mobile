import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configured via compile-time define: --dart-define=API_URL=https://api.yourdomain.com/api
  static const String _envApiUrl = String.fromEnvironment('API_URL');

  // Default local server port for development
  static const int port = 5000;

  // Dynamically resolve base URL based on environment or platform
  static String get baseUrl {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:$port/api';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the alias to the host loopback interface in Android emulator
      return 'http://10.0.2.2:$port/api';
    } else {
      return 'http://localhost:$port/api';
    }
  }
}
