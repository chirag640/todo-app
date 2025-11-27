import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/task_model.dart';

class TaskService {
  final ApiClient apiClient;

  TaskService(this.apiClient);

  /// Get all tasks
  Future<List<TaskModel>> getTasks({
    String? status,
    String? priority,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;

      final response = await apiClient.get(
        '/tasks',
        queryParameters: queryParams,
      );

      // Handle both paginated and wrapped response formats
      final responseData = response.data as Map<String, dynamic>;

      // Check if data is directly an array or wrapped in pagination
      final dataField = responseData['data'];
      List<dynamic> tasksList;

      if (dataField is List) {
        // Direct array response
        tasksList = dataField;
      } else if (dataField is Map<String, dynamic>) {
        // Paginated response with nested data
        tasksList = (dataField['data'] as List<dynamic>?) ?? [];
      } else {
        tasksList = [];
      }

      if (tasksList.isEmpty) {
        return [];
      }

      return tasksList
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single task by ID
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await apiClient.get('/tasks/$id');
      final responseData = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(responseData['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await apiClient.post(
        '/tasks',
        data: task.toJson(),
      );
      final responseData = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(responseData['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing task
  Future<TaskModel> updateTask(String id, TaskModel task) async {
    try {
      final response = await apiClient.patch(
        '/tasks/$id',
        data: task.toJson(),
      );
      final responseData = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(responseData['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a task (soft delete)
  Future<void> deleteTask(String id) async {
    try {
      await apiClient.delete('/tasks/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Toggle task completion status
  Future<TaskModel> toggleTaskCompletion(String id, bool isCompleted) async {
    try {
      final newStatus = isCompleted ? 'Completed' : 'Pending';
      final response = await apiClient.put(
        '/tasks/$id',
        data: {
          'status': newStatus,
          if (isCompleted) 'completedAt': DateTime.now().toIso8601String(),
        },
      );
      final responseData = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(responseData['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search tasks by title or description
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final response = await apiClient.get(
        '/tasks',
        queryParameters: {'search': query},
      );

      // Handle both paginated and wrapped response formats
      final responseData = response.data as Map<String, dynamic>;

      // Check if data is directly an array or wrapped in pagination
      final dataField = responseData['data'];
      List<dynamic> tasksList;

      if (dataField is List) {
        // Direct array response
        tasksList = dataField;
      } else if (dataField is Map<String, dynamic>) {
        // Paginated response with nested data
        tasksList = (dataField['data'] as List<dynamic>?) ?? [];
      } else {
        tasksList = [];
      }

      if (tasksList.isEmpty) {
        return [];
      }

      return tasksList
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Filter tasks by multiple criteria
  Future<List<TaskModel>> filterTasks({
    List<String>? priorities,
    String? sortBy,
    bool? isCompleted,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (priorities != null && priorities.isNotEmpty) {
        queryParams['priority'] = priorities.join(',');
      }

      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
        queryParams['order'] = 'desc';
      }

      if (isCompleted != null) {
        queryParams['status'] = isCompleted ? 'Completed' : 'Pending';
      }

      final response = await apiClient.get(
        '/tasks',
        queryParameters: queryParams,
      );

      // Handle both paginated and wrapped response formats
      final responseData = response.data as Map<String, dynamic>;

      // Check if data is directly an array or wrapped in pagination
      final dataField = responseData['data'];
      List<dynamic> tasksList;

      if (dataField is List) {
        // Direct array response
        tasksList = dataField;
      } else if (dataField is Map<String, dynamic>) {
        // Paginated response with nested data
        tasksList = (dataField['data'] as List<dynamic>?) ?? [];
      } else {
        tasksList = [];
      }

      if (tasksList.isEmpty) {
        return [];
      }

      return tasksList
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Failure _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkFailure(
          'Connection timeout. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkFailure(
          'No internet connection. Please check your network.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['message'] ?? 'An error occurred';

      if (statusCode == 400) {
        return ValidationFailure(message);
      } else if (statusCode == 401) {
        return UnauthorizedFailure(
            'Authentication failed. Please login again.');
      } else if (statusCode == 403) {
        return UnauthorizedFailure(
            'You do not have permission to perform this action.');
      } else if (statusCode == 404) {
        return ServerFailure('Task not found.');
      } else if (statusCode! >= 500) {
        return ServerFailure('Server error. Please try again later.');
      }
    }

    return ServerFailure('An unexpected error occurred.');
  }
}
