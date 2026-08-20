import 'package:flutter_test/flutter_test.dart';
import 'package:meetksa_customer/core/constants/permission_constants.dart';
import 'package:meetksa_customer/core/services/permission_service.dart';

void main() {
  group('PermissionService Unit Tests', () {
    late PermissionService permissionService;

    setUp(() {
      permissionService = PermissionService();
    });

    test('AppPermissionType extension titles match expected labels', () {
      expect(permissionService, isNotNull);
      expect(AppPermissionType.location.title, 'Location');
      expect(AppPermissionType.camera.title, 'Camera');
      expect(AppPermissionType.notifications.title, 'Notifications');
      expect(AppPermissionType.photosAndFiles.title, 'Photos & Files');
    });
  });
}
