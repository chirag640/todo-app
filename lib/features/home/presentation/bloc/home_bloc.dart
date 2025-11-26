import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

/// BLoC for managing home screen state
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitialState()) {
    on<IncrementCounterEvent>(_onIncrementCounter);
    on<LoadDataEvent>(_onLoadData);
    on<ResetHomeEvent>(_onResetHome);
  }

  /// Handles incrementing the counter
  Future<void> _onIncrementCounter(
    IncrementCounterEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoadedState) {
      final currentState = state as HomeLoadedState;
      emit(currentState.copyWith(counter: currentState.counter + 1));
    } else {
      emit(const HomeLoadedState(counter: 1));
    }
  }

  /// Handles loading data from API
  Future<void> _onLoadData(
    LoadDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoadingState());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Success - emit loaded state
      emit(const HomeLoadedState(
        counter: 0,
        message: 'Data loaded successfully!',
      ));
    } catch (e) {
      emit(HomeErrorState(message: e.toString()));
    }
  }

  /// Handles resetting the home state
  Future<void> _onResetHome(
    ResetHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeInitialState());
  }
}

