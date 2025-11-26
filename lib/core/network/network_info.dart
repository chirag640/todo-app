import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity monitor with enhanced features
class NetworkInfo extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkStatus _status = NetworkStatus.unknown;

  /// Get current network status
  NetworkStatus get status => _status;

  /// Check if connected
  bool get isConnected => _status.isConnected;

  /// Check if wifi
  bool get isWifi => _status.type == NetworkType.wifi;

  /// Check if mobile data
  bool get isMobile => _status.type == NetworkType.mobile;

  /// Stream of network status changes
  Stream<NetworkStatus> get statusStream {
    return _connectivity.onConnectivityChanged.map((results) {
      return _mapToStatus(results);
    });
  }

  /// Stream of boolean connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return !results.contains(ConnectivityResult.none);
    });
  }

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Get initial status
    final results = await _connectivity.checkConnectivity();
    _status = _mapToStatus(results);
    notifyListeners();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _status = _mapToStatus(results);
      notifyListeners();
    });
  }

  /// Map connectivity result to network status
  NetworkStatus _mapToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkStatus(
        isConnected: false,
        type: NetworkType.none,
      );
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return NetworkStatus(
        isConnected: true,
        type: NetworkType.wifi,
      );
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkStatus(
        isConnected: true,
        type: NetworkType.mobile,
      );
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkStatus(
        isConnected: true,
        type: NetworkType.ethernet,
      );
    }

    return NetworkStatus(
      isConnected: true,
      type: NetworkType.other,
    );
  }

  /// Wait for connection
  Future<void> waitForConnection({Duration? timeout}) async {
    if (isConnected) return;

    final completer = Completer<void>();
    StreamSubscription<NetworkStatus>? sub;
    Timer? timer;

    sub = statusStream.listen((status) {
      if (status.isConnected && !completer.isCompleted) {
        completer.complete();
        sub?.cancel();
        timer?.cancel();
      }
    });

    if (timeout != null) {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Connection timeout'));
          sub?.cancel();
        }
      });
    }

    return completer.future;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Network status
class NetworkStatus {
  final bool isConnected;
  final NetworkType type;

  const NetworkStatus({
    required this.isConnected,
    required this.type,
  });

  static const unknown = NetworkStatus(
    isConnected: false,
    type: NetworkType.none,
  );
}

/// Network type
enum NetworkType {
  none,
  wifi,
  mobile,
  ethernet,
  other,
}
