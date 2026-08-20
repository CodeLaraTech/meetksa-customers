import '../constants/app_urls.dart';

class UrlValidators {
  static bool isAllowedDomain(String urlString) {
    try {
      final Uri uri = Uri.parse(urlString);
      final String host = uri.host.toLowerCase();

      if (host.isEmpty) return false;

      return AppUrls.trustedHosts.contains(host) ||
          host == AppUrls.allowedDomain ||
          host.endsWith('.${AppUrls.trustedBaseDomain}');
    } catch (_) {
      return false;
    }
  }

  static bool isExternalScheme(String urlString) {
    try {
      final Uri uri = Uri.parse(urlString);
      final String scheme = uri.scheme.toLowerCase();

      return scheme == 'tel' ||
          scheme == 'mailto' ||
          scheme == 'whatsapp' ||
          scheme == 'sms' ||
          scheme == 'intent';
    } catch (_) {
      return false;
    }
  }

  static bool isValidUrl(String urlString) {
    try {
      final Uri uri = Uri.parse(urlString);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}
