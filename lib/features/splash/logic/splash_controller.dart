import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';

class SplashController extends ChangeNotifier {
  final ConnectivityService _connectivityService;
  final StorageService _storageService;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  SplashController({
    ConnectivityService? connectivityService,
    StorageService? storageService,
  })  : _connectivityService = connectivityService ?? ConnectivityService(),
        _storageService = storageService ?? StorageService();

  Future<void> initializeAndNavigate(BuildContext context) async {
    AppLogger.info('Initializing MeetKSA SplashController...');
    _isInitializing = true;
    notifyListeners();

    // Enforce splash screen display duration for smooth brand animation
    final stopwatch = Stopwatch()..start();

    // Perform background initialization tasks
    final connectionStatus = await _connectivityService.checkConnection();
    AppLogger.info('Initial connectivity status: $connectionStatus');
    final bool permissionsCompleted = await _storageService.isPermissionsCompleted();

    final int elapsed = stopwatch.elapsedMilliseconds;
    final int remaining = AppConstants.splashDuration.inMilliseconds - elapsed;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    _isInitializing = false;
    notifyListeners();

    if (!context.mounted) return;

    if (permissionsCompleted) {
      AppLogger.info('Permissions setup previously completed. Navigating to WebViewScreen.');
      Navigator.of(context).pushReplacementNamed(AppRoutes.webview);
    } else {
      AppLogger.info('First run / permissions setup required. Navigating to PermissionScreen.');
      Navigator.of(context).pushReplacementNamed(AppRoutes.permissionSetup);
    }
  }
}
