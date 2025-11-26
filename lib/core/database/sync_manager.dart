import 'dart:collection';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger.dart';
import '../network/network_info.dart';
import 'hive_database.dart';

/// Sync operation types
enum SyncOperationType {
  create,
  update,
  delete,
}

/// Pending sync operation
class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  final String id;
  final SyncOperationType type;
  final String endpoint;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'endpoint': endpoint,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.byName(json['type'] as String),
      endpoint: json['endpoint'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  SyncOperation copyWith({int? retryCount}) {
    return SyncOperation(
      id: id,
      type: type,
      endpoint: endpoint,
      data: data,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Manages offline-to-online data synchronization
class SyncManager extends ChangeNotifier {
  SyncManager({
    this.maxRetries = 3,
    NetworkInfo? networkInfo,
  }) : _networkInfo = networkInfo ?? NetworkInfo();

  final int maxRetries;
  final NetworkInfo _networkInfo;

  Box<Map>? _syncBox;
  final Queue<SyncOperation> _syncQueue = Queue<SyncOperation>();
  bool _isSyncing = false;
  bool _autoSyncEnabled = true;
  DateTime? _lastSyncTime;
  StreamSubscription<NetworkStatus>? _networkSubscription;

  /// Check if auto-sync is enabled
  bool get autoSyncEnabled => _autoSyncEnabled;

  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Initialize sync manager
  Future<void> initialize() async {
    _syncBox = await HiveDatabase.instance.openBox<Map>('sync_queue');
    await _loadPendingSyncs();

    // Initialize network monitoring
    await _networkInfo.initialize();

    // Listen for connectivity changes
    _networkSubscription = _networkInfo.statusStream.listen((status) {
      if (status.isConnected && _autoSyncEnabled) {
        sync();
      }
    });

    AppLogger.info('Sync manager initialized', 'SyncManager');

    // Initial sync if connected
    if (_networkInfo.isConnected) {
      await sync();
    }
  }

  /// Add operation to sync queue
  Future<void> addToQueue(SyncOperation operation) async {
    _ensureInitialized();

    await _syncBox!.put(operation.id, operation.toJson());
    _syncQueue.add(operation);

    AppLogger.debug(
      'Added to sync queue: ${operation.type.name} ${operation.endpoint}',
      'SyncManager',
    );

    notifyListeners();

    // Try to sync immediately if online
    if (_networkInfo.isConnected) {
      await sync();
    }
  }

  /// Process sync queue
  Future<void> sync() async {
    _ensureInitialized();

    if (_isSyncing) {
      AppLogger.debug('Sync already in progress', 'SyncManager');
      return;
    }

    if (_syncQueue.isEmpty) {
      AppLogger.debug('Sync queue is empty', 'SyncManager');
      return;
    }

    if (!_networkInfo.isConnected) {
      AppLogger.debug('No network connection', 'SyncManager');
      return;
    }

    _isSyncing = true;
    notifyListeners();

    AppLogger.info(
        'Starting sync (${_syncQueue.length} operations)', 'SyncManager');

    final failedOperations = <SyncOperation>[];

    while (_syncQueue.isNotEmpty) {
      final operation = _syncQueue.removeFirst();

      try {
        // TODO: Implement actual API calls based on operation type
        // For now, we'll simulate success
        await Future.delayed(const Duration(milliseconds: 100));

        // Remove from persistent storage
        await _syncBox!.delete(operation.id);

        AppLogger.success(
          'Synced: ${operation.type.name} ${operation.endpoint}',
          'SyncManager',
        );
      } catch (e, stackTrace) {
        AppLogger.error(
          'Sync failed: ${operation.endpoint}',
          e,
          stackTrace,
          'SyncManager',
        );

        // Retry logic
        if (operation.retryCount < maxRetries) {
          final retried =
              operation.copyWith(retryCount: operation.retryCount + 1);
          failedOperations.add(retried);
          await _syncBox!.put(retried.id, retried.toJson());
        } else {
          AppLogger.error(
            'Max retries reached for: ${operation.endpoint}',
            e,
            stackTrace,
            'SyncManager',
          );
        }
      }
    }

    // Re-add failed operations to queue
    _syncQueue.addAll(failedOperations);

    _isSyncing = false;
    _lastSyncTime = DateTime.now();
    notifyListeners();

    AppLogger.info('Sync completed', 'SyncManager');
  }

  /// Force sync now
  Future<void> forceSyncNow() async {
    await sync();
  }

  /// Enable/disable auto-sync
  void setAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
    notifyListeners();
  }

  /// Get pending sync count
  int get pendingCount => _syncQueue.length;

  /// Check if there are pending syncs
  bool get hasPendingSyncs => _syncQueue.isNotEmpty;

  /// Get sync statistics
  SyncStatistics getStatistics() {
    return SyncStatistics(
      pendingOperations: pendingCount,
      isConnected: _networkInfo.isConnected,
      lastSyncTime: _lastSyncTime,
      isSyncing: _isSyncing,
    );
  }

  /// Clear all pending syncs
  Future<void> clearQueue() async {
    _ensureInitialized();

    await _syncBox!.clear();
    _syncQueue.clear();
    notifyListeners();
    AppLogger.warning('Sync queue cleared', 'SyncManager');
  }

  void _ensureInitialized() {
    if (_syncBox == null || !_syncBox!.isOpen) {
      throw StateError('SyncManager not initialized. Call initialize() first.');
    }
  }

  Future<void> _loadPendingSyncs() async {
    for (final key in _syncBox!.keys) {
      final json = _syncBox!.get(key) as Map<String, dynamic>?;
      if (json == null) continue;

      try {
        final operation = SyncOperation.fromJson(json);
        _syncQueue.add(operation);
      } catch (e) {
        AppLogger.error(
            'Failed to load sync operation', e, null, 'SyncManager');
      }
    }

    AppLogger.info(
      'Loaded ${_syncQueue.length} pending syncs',
      'SyncManager',
    );
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    _networkInfo.dispose();
    super.dispose();
  }
}

/// Sync statistics
class SyncStatistics {
  final int pendingOperations;
  final bool isConnected;
  final DateTime? lastSyncTime;
  final bool isSyncing;

  SyncStatistics({
    required this.pendingOperations,
    required this.isConnected,
    this.lastSyncTime,
    required this.isSyncing,
  });
}
