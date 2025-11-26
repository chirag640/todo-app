import 'package:flutter/material.dart';

import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  static const home = '/';

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
