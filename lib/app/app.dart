import 'package:flutter/material.dart';

import 'app_config.dart';
import 'app_router.dart';
import 'app_theme.dart';

class MeetKSACustomerApp extends StatelessWidget {
  const MeetKSACustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.environment.appTitle,
      debugShowCheckedModeBanner: false,
      theme: MeetKSACustomerTheme.lightTheme,
      darkTheme: MeetKSACustomerTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
