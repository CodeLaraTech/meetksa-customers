/// Application environment configurations
enum AppEnvironment { production, staging, development }

class EnvironmentConfig {
  final AppEnvironment environment;
  final String appTitle;
  final String baseUrl;
  final bool enableDebugLogs;

  const EnvironmentConfig({
    required this.environment,
    required this.appTitle,
    required this.baseUrl,
    required this.enableDebugLogs,
  });

  static const EnvironmentConfig production = EnvironmentConfig(
    environment: AppEnvironment.production,
    appTitle: 'MeetKSA Customer',
    baseUrl: 'https://customer.meetksa.suitekonnect.com',
    enableDebugLogs: false,
  );

  static const EnvironmentConfig staging = EnvironmentConfig(
    environment: AppEnvironment.staging,
    appTitle: 'MeetKSA Customer Staging',
    baseUrl: 'https://customer.meetksa.suitekonnect.com',
    enableDebugLogs: true,
  );

  static const EnvironmentConfig development = EnvironmentConfig(
    environment: AppEnvironment.development,
    appTitle: 'MeetKSA Customer Dev',
    baseUrl: 'https://customer.meetksa.suitekonnect.com',
    enableDebugLogs: true,
  );

  EnvironmentConfig copyWith({
    AppEnvironment? environment,
    String? appTitle,
    String? baseUrl,
    bool? enableDebugLogs,
  }) {
    return EnvironmentConfig(
      environment: environment ?? this.environment,
      appTitle: appTitle ?? this.appTitle,
      baseUrl: baseUrl ?? this.baseUrl,
      enableDebugLogs: enableDebugLogs ?? this.enableDebugLogs,
    );
  }
}

