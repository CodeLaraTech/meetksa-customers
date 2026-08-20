import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  /// Fetches current high-accuracy native device coordinates (Android Fused / iOS CoreLocation)
  Future<Position> getCurrentLocation() async {
    AppLogger.info('LocationService: Fetching native device location...');

    // 1. Check if location services (GPS) are enabled on device
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.error('LocationService: Device location services are disabled.');
      throw LocationServiceException('Please enable Location Services on your device.');
    }

    // 2. Check & Request Native Location Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.error('LocationService: Native location permission denied.');
        throw LocationServiceException('Location permission is required to use your current location.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.error('LocationService: Native location permission permanently denied.');
      throw LocationServiceException('Location permission is permanently denied. Please open Settings to grant access.');
    }

    // 3. Fetch High-Accuracy Position with 15-second Timeout
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      AppLogger.info('LocationService: Successfully retrieved high-accuracy native coordinates.');
      return position;
    } on TimeoutException {
      AppLogger.error('LocationService: Native location request timed out after 15 seconds.');
      throw LocationServiceException('Location request timed out. Please try again.');
    } catch (e) {
      AppLogger.error('LocationService: Error getting native location', error: e);
      throw LocationServiceException('Unable to determine your current location. Please try again.');
    }
  }

  /// Opens native device Location Settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Opens native App Settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
