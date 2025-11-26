import 'package:equatable/equatable.dart';

/// Base class for all Home states
sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class HomeInitialState extends HomeState {
  const HomeInitialState();
}

/// State when data is being loaded
class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

/// State when data is successfully loaded
class HomeLoadedState extends HomeState {
  const HomeLoadedState({
    this.counter = 0,
    this.message,
  });

  final int counter;
  final String? message;

  @override
  List<Object?> get props => [counter, message];

  HomeLoadedState copyWith({
    int? counter,
    String? message,
  }) {
    return HomeLoadedState(
      counter: counter ?? this.counter,
      message: message ?? this.message,
    );
  }
}

/// State when an error occurs
class HomeErrorState extends HomeState {
  const HomeErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

