import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

enum ConnectionStatus { online, offline }

class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<ConnectionStatus> _statusController =
      StreamController<ConnectionStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectionStatus _currentStatus = ConnectionStatus.online;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _initListener();
  }

  Stream<ConnectionStatus> get onStatusChanged => _statusController.stream;
  ConnectionStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus == ConnectionStatus.online;

  void _initListener() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  /// Verifies actual internet reachability via Socket/DNS lookup
  Future<bool> hasActualInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('customer.meetksa.suitekonnect.com')
          .timeout(const Duration(seconds: 4));
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      try {
        final googleResult = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 4));
        if (googleResult.isNotEmpty && googleResult.first.rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  Future<ConnectionStatus> checkConnection() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      final bool hasInterface = results.any(
        (result) => result != ConnectivityResult.none,
      );

      if (!hasInterface) {
        _setNewStatus(ConnectionStatus.offline);
        return ConnectionStatus.offline;
      }

      final bool online = await hasActualInternetAccess();
      final ConnectionStatus newStatus =
          online ? ConnectionStatus.online : ConnectionStatus.offline;
      _setNewStatus(newStatus);
    } catch (e) {
      AppLogger.error('Failed to check connectivity', error: e);
      _setNewStatus(ConnectionStatus.offline);
    }
    return _currentStatus;
  }

  void _updateStatus(List<ConnectivityResult> results) async {
    final bool hasInterface = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasInterface) {
      _setNewStatus(ConnectionStatus.offline);
      return;
    }

    final bool online = await hasActualInternetAccess();
    final ConnectionStatus newStatus =
        online ? ConnectionStatus.online : ConnectionStatus.offline;
    _setNewStatus(newStatus);
  }

  void _setNewStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      AppLogger.info('Connectivity status changed: $_currentStatus');
      _statusController.add(_currentStatus);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
