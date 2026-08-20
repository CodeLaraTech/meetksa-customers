import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../constants/permission_constants.dart';
import '../utils/logger.dart';

class PermissionService {
  Future<AppPermissionStatus> checkStatus(AppPermissionType type) async {
    try {
      if (type == AppPermissionType.photosAndFiles && Platform.isAndroid) {
        final photosStatus = await Permission.photos.status;
        if (photosStatus.isGranted) return AppPermissionStatus.granted;
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) return AppPermissionStatus.granted;
        return _mapStatus(photosStatus.isPermanentlyDenied ? photosStatus : storageStatus);
      }
      final Permission permission = _getPermission(type);
      final PermissionStatus status = await permission.status;
      return _mapStatus(status);
    } catch (e) {
      AppLogger.error('Failed to check status for $type', error: e);
      return AppPermissionStatus.denied;
    }
  }

  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async {
    try {
      // 1. If permission is already granted, return granted immediately without prompting again
      final AppPermissionStatus currentStatus = await checkStatus(type);
      if (currentStatus == AppPermissionStatus.granted) {
        return AppPermissionStatus.granted;
      }

      // 2. Request permission if not yet granted
      if (type == AppPermissionType.photosAndFiles && Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) {
          AppLogger.info('Requested permission photos: $photosStatus');
          return AppPermissionStatus.granted;
        }

        final storageStatus = await Permission.storage.request();
        AppLogger.info('Requested permission storage: $storageStatus');
        return _mapStatus(storageStatus);
      }

      final Permission permission = _getPermission(type);
      final PermissionStatus status = await permission.request();
      AppLogger.info('Requested permission $type: $status');
      return _mapStatus(status);
    } catch (e) {
      AppLogger.error('Error requesting permission $type', error: e);
      return AppPermissionStatus.denied;
    }
  }

  Future<Map<AppPermissionType, AppPermissionStatus>> checkAllPermissions() async {
    final Map<AppPermissionType, AppPermissionStatus> resultMap = {};
    for (final type in AppPermissionType.values) {
      resultMap[type] = await checkStatus(type);
    }
    return resultMap;
  }

  Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      AppLogger.error('Failed to open app settings', error: e);
      return false;
    }
  }

  Permission _getPermission(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.location:
        return Permission.locationWhenInUse;
      case AppPermissionType.camera:
        return Permission.camera;
      case AppPermissionType.notifications:
        return Permission.notification;
      case AppPermissionType.photosAndFiles:
        return Platform.isAndroid ? Permission.storage : Permission.photos;
    }
  }

  AppPermissionStatus _mapStatus(PermissionStatus status) {
    if (status.isGranted) {
      return AppPermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    } else if (status.isRestricted) {
      return AppPermissionStatus.restricted;
    } else if (status.isLimited) {
      return AppPermissionStatus.limited;
    } else {
      return AppPermissionStatus.denied;
    }
  }
}
