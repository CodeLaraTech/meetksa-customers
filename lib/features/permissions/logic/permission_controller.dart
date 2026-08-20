import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/permission_constants.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';

class PermissionController extends ChangeNotifier {
  final PermissionService _permissionService;
  final StorageService _storageService;

  Map<AppPermissionType, AppPermissionStatus> _permissionStatuses = {};
  Map<AppPermissionType, AppPermissionStatus> get permissionStatuses => _permissionStatuses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PermissionController({
    PermissionService? permissionService,
    StorageService? storageService,
  })  : _permissionService = permissionService ?? PermissionService(),
        _storageService = storageService ?? StorageService() {
    loadStatuses();
  }

  Future<void> loadStatuses() async {
    _isLoading = true;
    notifyListeners();

    _permissionStatuses = await _permissionService.checkAllPermissions();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> requestPermission(AppPermissionType type) async {
    AppLogger.info('Controller requesting permission: $type');
    final status = await _permissionService.requestPermission(type);
    _permissionStatuses[type] = status;
    notifyListeners();

    if (status == AppPermissionStatus.permanentlyDenied) {
      await _permissionService.openAppSettings();
    }
  }

  Future<void> requestAllPermissions() async {
    AppLogger.info('Controller requesting ALL permissions at once');
    _isLoading = true;
    notifyListeners();

    final List<AppPermissionType> permissions = [
      AppPermissionType.location,
      AppPermissionType.camera,
      AppPermissionType.notifications,
      AppPermissionType.photosAndFiles,
    ];

    for (final type in permissions) {
      final status = await _permissionService.requestPermission(type);
      _permissionStatuses[type] = status;
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeSetupAndProceed(BuildContext context) async {
    AppLogger.info('Completing permission setup and proceeding to WebViewScreen');
    await _storageService.setPermissionsCompleted(true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.webview);
  }
}
