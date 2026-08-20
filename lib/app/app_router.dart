import 'package:flutter/material.dart';

import '../features/error/presentation/screens/error_screen.dart';
import '../features/permissions/presentation/screens/permission_center_screen.dart';
import '../features/permissions/presentation/screens/permission_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/webview/presentation/screens/webview_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String permissionSetup = '/permission-setup';
  static const String permissionCenter = '/permission-center';
  static const String webview = '/webview';
  static const String error = '/error';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case permissionSetup:
        return MaterialPageRoute(
          builder: (_) => const PermissionScreen(),
          settings: settings,
        );
      case permissionCenter:
        return MaterialPageRoute(
          builder: (_) => const PermissionCenterScreen(),
          settings: settings,
        );
      case webview:
        return MaterialPageRoute(
          builder: (_) => const WebViewScreen(),
          settings: settings,
        );
      case error:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ErrorScreen(
            errorMessage: args?['message'] as String?,
            onRetry: args?['onRetry'] as VoidCallback?,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}
