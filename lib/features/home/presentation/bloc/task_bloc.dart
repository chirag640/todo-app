import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/task_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService taskService;

  TaskBloc(this.taskService) : super(const TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
    on<SearchTasksEvent>(_onSearchTasks);
    on<FilterTasksEvent>(_onFilterTasks);
    on<ClearFiltersEvent>(_onClearFilters);
    on<RefreshTasksEvent>(_onRefreshTasks);
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    try {
      final tasks = await taskService.getTasks();

      if (tasks.isEmpty) {
        emit(const TaskEmpty('No tasks yet. Create your first task!'));
      } else {
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskOperationInProgress());

    try {
      await taskService.createTask(event.task);
      final tasks = await taskService.getTasks();

      emit(TaskOperationSuccess('Task created successfully', tasks));
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to create task: ${e.toString()}'));

      // Reload tasks to restore previous state
      try {
        final tasks = await taskService.getTasks();
        emit(TaskLoaded(tasks));
      } catch (_) {}
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskOperationInProgress());

    try {
      await taskService.updateTask(event.id, event.task);
      final tasks = await taskService.getTasks();

      emit(TaskOperationSuccess('Task updated successfully', tasks));
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to update task: ${e.toString()}'));

      // Reload tasks to restore previous state
      try {
        final tasks = await taskService.getTasks();
        emit(TaskLoaded(tasks));
      } catch (_) {}
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskOperationInProgress());

    try {
      await taskService.deleteTask(event.id);
      final tasks = await taskService.getTasks();

      emit(TaskOperationSuccess('Task deleted successfully', tasks));

      if (tasks.isEmpty) {
        emit(const TaskEmpty('No tasks yet. Create your first task!'));
      } else {
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      emit(TaskError('Failed to delete task: ${e.toString()}'));

      // Reload tasks to restore previous state
      try {
        final tasks = await taskService.getTasks();
        emit(TaskLoaded(tasks));
      } catch (_) {}
    }
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletionEvent event,
    Emitter<TaskState> emit,
  ) async {
    // Keep current state visible while updating
    final currentState = state;

    try {
      await taskService.toggleTaskCompletion(event.id, event.isCompleted);
      final tasks = await taskService.getTasks();

      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to update task: ${e.toString()}'));

      // Restore previous state
      if (currentState is TaskLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onSearchTasks(
    SearchTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    try {
      final tasks = event.query.isEmpty
          ? await taskService.getTasks()
          : await taskService.searchTasks(event.query);

      if (tasks.isEmpty) {
        emit(const TaskEmpty('No tasks found matching your search'));
      } else {
        emit(TaskLoaded(tasks, isSearching: event.query.isNotEmpty));
      }
    } catch (e) {
      emit(TaskError('Failed to search tasks: ${e.toString()}'));
    }
  }

  Future<void> _onFilterTasks(
    FilterTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    try {
      final tasks = await taskService.filterTasks(
        priorities: event.priorities,
        sortBy: event.sortBy,
        isCompleted: event.isCompleted,
      );

      if (tasks.isEmpty) {
        emit(const TaskEmpty('No tasks found matching your filters'));
      } else {
        emit(TaskLoaded(tasks, isFiltered: true));
      }
    } catch (e) {
      emit(TaskError('Failed to filter tasks: ${e.toString()}'));
    }
  }

  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    try {
      final tasks = await taskService.getTasks();

      if (tasks.isEmpty) {
        emit(const TaskEmpty('No tasks yet. Create your first task!'));
      } else {
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onRefreshTasks(
    RefreshTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    // Don't show loading for refresh
    try {
      final tasks = await taskService.getTasks();

      if (tasks.isEmpty) {
        emit(const TaskEmpty('No tasks yet. Create your first task!'));
      } else {
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      // Keep current state on refresh error
      if (state is! TaskLoaded) {
        emit(TaskError(e.toString()));
      }
    }
  }
}
