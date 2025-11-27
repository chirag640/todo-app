import 'package:equatable/equatable.dart';
import '../../data/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Load all tasks
class LoadTasksEvent extends TaskEvent {
  const LoadTasksEvent();
}

/// Create a new task
class CreateTaskEvent extends TaskEvent {
  final TaskModel task;

  const CreateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

/// Update an existing task
class UpdateTaskEvent extends TaskEvent {
  final String id;
  final TaskModel task;

  const UpdateTaskEvent(this.id, this.task);

  @override
  List<Object?> get props => [id, task];
}

/// Delete a task
class DeleteTaskEvent extends TaskEvent {
  final String id;

  const DeleteTaskEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Toggle task completion
class ToggleTaskCompletionEvent extends TaskEvent {
  final String id;
  final bool isCompleted;

  const ToggleTaskCompletionEvent(this.id, this.isCompleted);

  @override
  List<Object?> get props => [id, isCompleted];
}

/// Search tasks
class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter tasks
class FilterTasksEvent extends TaskEvent {
  final List<String>? priorities;
  final String? sortBy;
  final String? status;
  final String? dateFilter;

  const FilterTasksEvent({
    this.priorities,
    this.sortBy,
    this.status,
    this.dateFilter,
  });

  @override
  List<Object?> get props => [priorities, sortBy, status, dateFilter];
}

/// Clear search/filter and reload all tasks
class ClearFiltersEvent extends TaskEvent {
  const ClearFiltersEvent();
}

/// Refresh tasks (pull to refresh)
class RefreshTasksEvent extends TaskEvent {
  const RefreshTasksEvent();
}
