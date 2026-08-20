import 'package:flutter/services.dart';

import '../utils/logger.dart';

/// Reads ALL cookies for a URL from Android's native CookieManager,
/// including HttpOnly session cookies that JavaScript cannot access.
class NativeCookieService {
  static const _channel = MethodChannel('meetksa/cookies');

  static final NativeCookieService _instance = NativeCookieService._();
  factory NativeCookieService() => _instance;
  NativeCookieService._();

  Future<String> getCookiesForUrl(String url) async {
    try {
      final result = await _channel.invokeMethod<String>('getCookies', {'url': url});
      final cookies = result ?? '';
      AppLogger.info('NativeCookieService: Got ${cookies.length} chars of cookies for $url');
      return cookies;
    } catch (e) {
      AppLogger.error('NativeCookieService: Failed to get cookies', error: e);
      return '';
    }
  }
}
