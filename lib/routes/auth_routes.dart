import 'package:flutter/material.dart';
import 'package:controller/src/screens/auth/signin_screen.dart';
import 'package:controller/src/screens/auth/signup_screen.dart';
import 'package:controller/src/screens/auth/welcome_screen.dart';

import '../src/screens/auth/auth_management.dart';

class AuthRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String welcome = '/welcome';
  static const String checkAuth = '/check-auth';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      checkAuth: (context) => const AuthGate(),
      signup: (context) => const SignUpScreen(),
      login: (context) => const SignInScreen(),
    };
  }
}
