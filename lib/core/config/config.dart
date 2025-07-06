import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String get googleClientId {
    if (Platform.isIOS) {
      return dotenv.env['IOS_CLIENT_ID'] ?? '';
    } else {
      return dotenv.env['ANDROID_CLIENT_ID'] ?? '';
    }
  }
}
