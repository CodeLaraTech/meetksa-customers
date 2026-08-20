import '../config/environment.dart';

class AppConfig {
  static EnvironmentConfig environment = EnvironmentConfig.production;

  static void initialize({required EnvironmentConfig config}) {
    environment = config;
  }
}
