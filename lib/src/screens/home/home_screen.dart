import 'dart:async';
import 'dart:ui';
import 'package:controller/src/controllers/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:controller/src/controllers/desk/bluetooth_controller.dart';
import 'package:controller/src/screens/control/control_screen.dart';
import 'package:controller/src/screens/settings/settings_screen.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:provider/provider.dart';
import '../../../routes/auth_routes.dart';
import '../../controllers/desk/desk_controller.dart';
import '../statics/statics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late StreamSubscription<User?> _authStateSubscription;
  PageController pageController = PageController();

  changeIndex(int newIndex) {
    index = newIndex;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<BluetoothController>().listenToAdapterState();
    _listenToAuthState();
    context.read<AuthController>().initializeNotifications(context);
  }

  void _listenToAuthState() {
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out or session expired
        Navigator.of(context).pushReplacementNamed(AuthRoutes.welcome);
      }
    });
  }

  @override
  dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBlur(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            PageView(
              onPageChanged: changeIndex,
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ControlScreen(),
                StatisticsScreen(),
                SettingsScreen(),
              ],
            ),
            // if (deskController.deviceReady)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _buildCustomNavigationBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNavigationBar() {
    double indicatorPosition = MediaQuery.of(context).size.width * 0.0 +
        (index * MediaQuery.of(context).size.width * 0.25);

    return ClipRRect(
      key: menuKey,
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Indicador que se mueve
            AnimatedPositioned(
              left: indicatorPosition,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _buildIndicatorBack(),
            ),
            Container(
              height: kBottomNavigationBarHeight,
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).navigationBarTheme.backgroundColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color:
                        Theme.of(context).navigationBarTheme.backgroundColor!,
                    width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 0),
                  _buildNavItem(Icons.analytics, 1),
                  _buildNavItem(Icons.settings, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Indicador que se moverá detrás del ícono seleccionado
  Widget _buildIndicatorBack() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      height: kBottomNavigationBarHeight,
      decoration: BoxDecoration(
        color: Colors.cyan,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int i) {
    final bool isSelected = index == i;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        pageController.jumpToPage(i);
      },
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width /
            4.1, // Ocupa 1/3 del ancho de la pantalla
        height: kBottomNavigationBarHeight,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 25,
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.displayLarge!.color,
        ),
      ),
    );
  }
}
