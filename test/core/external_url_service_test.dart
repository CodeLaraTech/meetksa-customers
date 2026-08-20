import 'package:flutter_test/flutter_test.dart';
import 'package:meetksa_customer/core/services/external_url_service.dart';

void main() {
  group('ExternalUrlService Tests', () {
    late ExternalUrlService externalUrlService;

    setUp(() {
      externalUrlService = ExternalUrlService();
    });

    test('ExternalUrlService instantiates correctly', () {
      expect(externalUrlService, isNotNull);
    });
  });
}
