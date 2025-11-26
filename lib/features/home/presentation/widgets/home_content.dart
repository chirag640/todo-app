import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../bloc/home_event.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';

/// Home screen content widget using BlocBuilder
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoadingState) {
          return const LoadingIndicator(message: 'Loading...');
        }

        if (state is HomeErrorState) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<HomeBloc>().add(const LoadDataEvent()),
          );
        }

        if (state is HomeLoadedState) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Counter: ${state.counter}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'BLoC Pattern Demo',
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const LoadDataEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 1.8.h,
                      ),
                    ),
                    child: Text(
                      'Load Data',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Initial state - show welcome screen
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 15.h,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 3.h),
                Text(
                  'Welcome to Todo App',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tap the + button to increment counter',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<HomeBloc>().add(const LoadDataEvent());
                  },
                  icon: Icon(Icons.cloud_download, size: 18.sp),
                  label: Text(
                    'Load Data',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 1.8.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
