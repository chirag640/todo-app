import 'package:equatable/equatable.dart';

/// Base class for all Home events
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to increment the counter
class IncrementCounterEvent extends HomeEvent {
  const IncrementCounterEvent();
}

/// Event to load data from API
class LoadDataEvent extends HomeEvent {
  const LoadDataEvent();
}

/// Event to reset the home state
class ResetHomeEvent extends HomeEvent {
  const ResetHomeEvent();
}

