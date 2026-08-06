import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Use local server port
  static const int port = 5000;

  // Dynamically resolve base URL based on platform/environment
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the special alias to the host loopback interface in Android emulator
      // For physical Android devices, you may want to set it to your computer's local IP address (e.g. 192.168.x.x)
      return 'http://10.0.2.2:$port/api';
    } else {
      return 'http://localhost:$port/api';
    }
  }
}
