import 'app_strings.dart';

enum AppPermissionType {
  location,
  camera,
  notifications,
  photosAndFiles,
}

enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

extension AppPermissionTypeExtension on AppPermissionType {
  String get title {
    switch (this) {
      case AppPermissionType.location:
        return AppStrings.permissionLocationTitle;
      case AppPermissionType.camera:
        return AppStrings.permissionCameraTitle;
      case AppPermissionType.notifications:
        return AppStrings.permissionNotificationsTitle;
      case AppPermissionType.photosAndFiles:
        return AppStrings.permissionPhotosFilesTitle;
    }
  }

  String get description {
    switch (this) {
      case AppPermissionType.location:
        return AppStrings.permissionLocationDesc;
      case AppPermissionType.camera:
        return AppStrings.permissionCameraDesc;
      case AppPermissionType.notifications:
        return AppStrings.permissionNotificationsDesc;
      case AppPermissionType.photosAndFiles:
        return AppStrings.permissionPhotosFilesDesc;
    }
  }
}

