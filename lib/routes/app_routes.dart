import 'package:flutter/material.dart';
import 'package:controller/src/screens/home/home_screen.dart';
import 'auth_routes.dart';
import 'settings_routes.dart';

class AppRoutes {
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      ...AuthRoutes.getRoutes(),
      ...SettingsRoutes.getRoutes(),
    };
  }
}
