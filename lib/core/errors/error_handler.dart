import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../utils/logger.dart';
import 'app_exception.dart';

class ErrorHandler {
  static String getDisplayMessage(dynamic error) {
    if (error is NetworkException) {
      return AppStrings.noInternetMessage;
    } else if (error is WebViewException) {
      return AppStrings.defaultErrorMessage;
    } else if (error is PermissionException) {
      return AppStrings.permissionCenterLimitedSummary;
    } else if (error is ExternalUrlException) {
      return AppStrings.externalUrlLaunchError;
    } else if (error is AppException) {
      return error.message;
    }
    return AppStrings.defaultErrorMessage;
  }

  static void handleError(BuildContext context, dynamic error, {StackTrace? stackTrace}) {
    AppLogger.error('Handled Error: $error', error: error, stackTrace: stackTrace);

    final String message = getDisplayMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF93000A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
