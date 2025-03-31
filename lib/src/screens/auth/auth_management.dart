import 'package:controller/src/controllers/routines/routine_controller.dart';
import 'package:controller/src/controllers/settings/measurement_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:controller/src/controllers/auth/auth_controller.dart';
import 'package:controller/src/controllers/desk/bluetooth_controller.dart';
import 'package:controller/src/screens/auth/welcome_screen.dart';
import 'package:controller/src/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //set user data
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // user is logged in
            if (snapshot.connectionState == ConnectionState.active) {
              context.read<BluetoothController>().listenToAdapterState();
              context.read<AuthController>().loadUserData();
              context.read<MeasurementController>().loadPreferences();
              context.read<RoutineController>().loadRoutine();
              return const HomeScreen();
            } else {
              return const WelcomeScreen();
            }
          }),
    );
  }
}
