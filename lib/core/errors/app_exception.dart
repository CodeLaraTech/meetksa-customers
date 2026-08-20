class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: [$code] $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

class WebViewException extends AppException {
  const WebViewException(super.message, {super.code, super.details});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.details});
}

class ExternalUrlException extends AppException {
  const ExternalUrlException(super.message, {super.code, super.details});
}
