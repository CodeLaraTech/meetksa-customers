import '../../app/app_config.dart';

class AppUrls {
  static String get baseUrl => AppConfig.environment.baseUrl;
  static String get initialUrl => '$baseUrl/login.html';
  static String get mainWebViewUrl => initialUrl;

  static String get allowedDomain {
    try {
      final uri = Uri.parse(baseUrl);
      return uri.host.isNotEmpty ? uri.host : 'customer.meetksa.suitekonnect.com';
    } catch (_) {
      return 'customer.meetksa.suitekonnect.com';
    }
  }

  static const String trustedBaseDomain = 'suitekonnect.com';

  static List<String> get trustedHosts {
    final host = allowedDomain;
    final hosts = <String>{
      host,
      'customer.meetksa.suitekonnect.com',
      'suitekonnect.com',
      'meetksa.com',
    };
    return hosts.toList();
  }

  static const List<String> supportedSchemes = [
    'http',
    'https',
    'tel',
    'mailto',
    'whatsapp',
  ];
}

