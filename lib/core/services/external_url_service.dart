import 'package:url_launcher/url_launcher.dart';
import '../constants/app_strings.dart';
import '../errors/app_exception.dart';
import '../utils/logger.dart';
import '../utils/validators.dart';

class ExternalUrlService {
  Future<bool> launchExternalUrl(String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);

      if (UrlValidators.isExternalScheme(urlString) || !UrlValidators.isAllowedDomain(urlString)) {
        AppLogger.info('Launching external URL/Scheme: $urlString');
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw ExternalUrlException('${AppStrings.externalUrlLaunchError}: $urlString');
        }
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to launch external URL: $urlString', error: e);
      throw ExternalUrlException('${AppStrings.externalUrlLaunchError}: $e');
    }
  }
}
