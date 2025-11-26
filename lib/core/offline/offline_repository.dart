import 'dart:async';
import '../database/sync_manager.dart';

/// Offline-first repository pattern.
///
/// Usage:
/// ```dart
/// final repository = OfflineRepository<Post>(
///   localDataSource: localDb,
///   remoteDataSource: api,
///   syncManager: syncManager,
/// );
///
/// final posts = await repository.getAll();
/// await repository.create(newPost);
/// ```
abstract class OfflineRepository<T> {
  final LocalDataSource<T> localDataSource;
  final RemoteDataSource<T> remoteDataSource;
  final SyncManager? syncManager;

  OfflineRepository({
    required this.localDataSource,
    required this.remoteDataSource,
    this.syncManager,
  });

  /// Get all items (local first)
  Future<List<T>> getAll() async {
    try {
      // Try local first
      final localData = await localDataSource.getAll();

      // Sync in background
      _syncInBackground();

      return localData;
    } catch (e) {
      // Fallback to remote if local fails
      return await remoteDataSource.getAll();
    }
  }

  /// Get item by ID (local first)
  Future<T?> getById(String id) async {
    try {
      // Try local first
      final localData = await localDataSource.getById(id);

      if (localData != null) return localData;

      // Try remote if not in local
      final remoteData = await remoteDataSource.getById(id);

      if (remoteData != null) {
        await localDataSource.save(remoteData);
      }

      return remoteData;
    } catch (e) {
      return await localDataSource.getById(id);
    }
  }

  /// Create item (save locally, queue for sync)
  Future<T> create(T item) async {
    // Save locally first
    await localDataSource.save(item);

    // Queue for sync
    if (syncManager != null) {
      await syncManager!.addToQueue(SyncOperation(
        id: _generateId(),
        type: SyncOperationType.create,
        endpoint: '/items',
        data: _toMap(item),
        timestamp: DateTime.now(),
      ));
    } else {
      // Try immediate sync
      try {
        await remoteDataSource.create(item);
      } catch (e) {
        // Silent fail, will sync later
      }
    }

    return item;
  }

  /// Update item (save locally, queue for sync)
  Future<T> update(T item) async {
    // Save locally first
    await localDataSource.update(item);

    // Queue for sync
    if (syncManager != null) {
      await syncManager!.addToQueue(SyncOperation(
        id: _generateId(),
        type: SyncOperationType.update,
        endpoint: '/items',
        data: _toMap(item),
        timestamp: DateTime.now(),
      ));
    } else {
      // Try immediate sync
      try {
        await remoteDataSource.update(item);
      } catch (e) {
        // Silent fail, will sync later
      }
    }

    return item;
  }

  /// Delete item (delete locally, queue for sync)
  Future<void> delete(String id) async {
    // Delete locally first
    await localDataSource.delete(id);

    // Queue for sync
    if (syncManager != null) {
      await syncManager!.addToQueue(SyncOperation(
        id: _generateId(),
        type: SyncOperationType.delete,
        endpoint: '/items/$id',
        data: {'id': id},
        timestamp: DateTime.now(),
      ));
    } else {
      // Try immediate sync
      try {
        await remoteDataSource.delete(id);
      } catch (e) {
        // Silent fail, will sync later
      }
    }
  }

  /// Sync local and remote data
  Future<void> sync() async {
    try {
      final remoteData = await remoteDataSource.getAll();
      final localData = await localDataSource.getAll();

      // Simple merge strategy: remote wins
      for (final remote in remoteData) {
        await localDataSource.save(remote);
      }

      // Push local changes
      for (final local in localData) {
        try {
          await remoteDataSource.update(local);
        } catch (e) {
          // Item might not exist remotely, try create
          try {
            await remoteDataSource.create(local);
          } catch (e) {
            // Ignore errors
          }
        }
      }
    } catch (e) {
      // Sync failed, will retry later
    }
  }

  /// Background sync
  void _syncInBackground() {
    Future.delayed(Duration.zero, () async {
      try {
        await sync();
      } catch (e) {
        // Silent fail
      }
    });
  }

  /// Convert item to map (to be implemented by subclasses)
  Map<String, dynamic> _toMap(T item);

  /// Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Local data source interface
abstract class LocalDataSource<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
  Future<void> clear();
}

/// Remote data source interface
abstract class RemoteDataSource<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> delete(String id);
}
