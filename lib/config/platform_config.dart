import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformConfig {
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  static String get userAgentSuffix => 'MeetKSACustomerMobileShell/1.0.0';
}
