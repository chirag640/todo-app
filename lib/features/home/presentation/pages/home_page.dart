import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../widgets/home_content.dart';

/// Home page with BLoC state management
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo App',
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: const HomeContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<HomeBloc>().add(const IncrementCounterEvent());
        },
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }
}
