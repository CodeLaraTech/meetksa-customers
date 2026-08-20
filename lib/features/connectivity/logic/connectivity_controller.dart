import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/connectivity_service.dart';

class ConnectivityController extends ChangeNotifier {
  final ConnectivityService _connectivityService;

  ConnectionStatus _status = ConnectionStatus.online;
  ConnectionStatus get status => _status;
  bool get isOnline => _status == ConnectionStatus.online;

  StreamSubscription<ConnectionStatus>? _subscription;

  ConnectivityController({ConnectivityService? connectivityService})
      : _connectivityService = connectivityService ?? ConnectivityService() {
    _status = _connectivityService.currentStatus;
    _subscription = _connectivityService.onStatusChanged.listen((newStatus) {
      _status = newStatus;
      notifyListeners();
    });
  }

  Future<void> checkConnection() async {
    _status = await _connectivityService.checkConnection();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
