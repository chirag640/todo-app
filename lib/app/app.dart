import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../core/routing/app_router.dart';
import '../features/home/presentation/bloc/home_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => HomeBloc(),
            ),
            // Add more BLoCs here
          ],
          child: MaterialApp(
            title: 'Todo App',
            debugShowCheckedModeBanner: false,
            initialRoute: AppRouter.home,
            onGenerateRoute: router.onGenerateRoute,
          ),
        );
      },
    );
  }
}
