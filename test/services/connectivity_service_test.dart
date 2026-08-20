import 'package:flutter_test/flutter_test.dart';
import 'package:meetksa_customer/core/services/connectivity_service.dart';

void main() {
  group('ConnectivityService Unit Tests', () {
    test('ConnectionStatus values match online and offline', () {
      expect(ConnectionStatus.online.name, 'online');
      expect(ConnectionStatus.offline.name, 'offline');
    });
  });
}
