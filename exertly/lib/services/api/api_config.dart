import 'package:flutter/foundation.dart';

/// Base URL for the Exertly.Api backend (see /Exertly.Api).
/// Points at the plain-HTTP dev profile (launchSettings.json) so local
/// development doesn't require trusting a self-signed HTTPS dev cert.
class ApiConfig {
  ApiConfig._();

  static const String _devPort = '5219';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$_devPort';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // 10.0.2.2 routes to the host machine from the Android emulator.
        return 'http://10.0.2.2:$_devPort';
      default:
        return 'http://localhost:$_devPort';
    }
  }
}
