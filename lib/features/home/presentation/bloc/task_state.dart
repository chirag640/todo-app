import 'package:equatable/equatable.dart';
import '../../data/models/task_model.dart';
import '../../../../core/errors/failures.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Loading state
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Tasks loaded successfully
class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  final bool isSearching;
  final bool isFiltered;

  const TaskLoaded(
    this.tasks, {
    this.isSearching = false,
    this.isFiltered = false,
  });

  @override
  List<Object?> get props => [tasks, isSearching, isFiltered];

  TaskLoaded copyWith({
    List<TaskModel>? tasks,
    bool? isSearching,
    bool? isFiltered,
  }) {
    return TaskLoaded(
      tasks ?? this.tasks,
      isSearching: isSearching ?? this.isSearching,
      isFiltered: isFiltered ?? this.isFiltered,
    );
  }
}

/// Task operation in progress (for create, update, delete)
class TaskOperationInProgress extends TaskState {
  const TaskOperationInProgress();
}

/// Task operation successful
class TaskOperationSuccess extends TaskState {
  final String message;
  final List<TaskModel> tasks;

  const TaskOperationSuccess(this.message, this.tasks);

  @override
  List<Object?> get props => [message, tasks];
}

/// Error state
class TaskError extends TaskState {
  final String message;
  final Failure? failure;

  const TaskError(this.message, {this.failure});

  @override
  List<Object?> get props => [message, failure];
}

/// Empty state (no tasks)
class TaskEmpty extends TaskState {
  final String message;

  const TaskEmpty(this.message);

  @override
  List<Object?> get props => [message];
}
