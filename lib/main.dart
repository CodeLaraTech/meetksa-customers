import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'config/environment.dart';
import 'core/services/notification_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure app environment
  AppConfig.initialize(config: EnvironmentConfig.production);

  // Configure logger
  AppLogger.configure(enableDebugLogs: AppConfig.environment.enableDebugLogs);

  // Initialize Notification Service for Native Phone Notifications
  await NotificationService().initialize();

  AppLogger.info('Starting MeetKSA Customer Mobile Shell...');

  runApp(const MeetKSACustomerApp());
}
