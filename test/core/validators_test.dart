import 'package:flutter_test/flutter_test.dart';
import 'package:meetksa_customer/app/app_config.dart';
import 'package:meetksa_customer/config/environment.dart';
import 'package:meetksa_customer/core/utils/validators.dart';

void main() {
  setUpAll(() {
    AppConfig.initialize(config: EnvironmentConfig.production);
  });

  group('UrlValidators Tests', () {
    test('isAllowedDomain returns true for target customer URL domain', () {
      expect(
        UrlValidators.isAllowedDomain('https://customer.meetksa.suitekonnect.com/login.html'),
        isTrue,
      );
    });

    test('isAllowedDomain returns true for suitekonnect subdomains', () {
      expect(
        UrlValidators.isAllowedDomain('https://app.suitekonnect.com/dashboard'),
        isTrue,
      );
    });

    test('isAllowedDomain returns false for untrusted third-party domain', () {
      expect(
        UrlValidators.isAllowedDomain('https://malicious-website.com/phishing'),
        isFalse,
      );
    });

    test('isExternalScheme correctly identifies tel, mailto, and whatsapp', () {
      expect(UrlValidators.isExternalScheme('tel:+966500000000'), isTrue);
      expect(UrlValidators.isExternalScheme('mailto:support@suitekonnect.com'), isTrue);
      expect(UrlValidators.isExternalScheme('whatsapp://send?phone=966500000000'), isTrue);
      expect(UrlValidators.isExternalScheme('https://suitekonnect.com'), isFalse);
    });
  });
}
