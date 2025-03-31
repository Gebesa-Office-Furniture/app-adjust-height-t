import 'package:controller/src/controllers/statistics/statistics_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:controller/firebase_options.dart';
import 'package:controller/routes/auth_routes.dart';
import 'package:controller/src/controllers/auth/auth_controller.dart';
import 'package:controller/src/controllers/network/connectivity_controller.dart';
import 'package:controller/src/controllers/user/user_controller.dart';
import 'package:controller/src/config/style/app_theme.dart';
import 'package:controller/src/controllers/desk/bluetooth_controller.dart';
import 'package:controller/src/controllers/desk/desk_controller.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'routes/app_routes.dart';
import 'src/controllers/routines/routine_controller.dart';
import 'src/controllers/settings/language_controller.dart';
import 'src/controllers/settings/measurement_controller.dart';
import 'src/controllers/settings/theme_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  var binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(create: (_) => LanguageController()),
      ChangeNotifierProvider(create: (_) => BluetoothController()),
      ChangeNotifierProvider(create: (_) => DeskController()),
      ChangeNotifierProvider(create: (_) => MeasurementController()),
      ChangeNotifierProvider(create: (_) => UserController()),
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(create: (_) => ConnectivityController()),
      ChangeNotifierProvider(create: (_) => RoutineController()),
      ChangeNotifierProvider(create: (_) => StatisticsController()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeController = Provider.of<ThemeController>(context);
    var languageController = Provider.of<LanguageController>(context);
    return ToastificationWrapper(
      child: MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(0.95),
            ), //set desired text scale factor here
            child: child!,
          );
        },
        title: 'Gebesa Desk Controller',
        debugShowCheckedModeBanner: false,
        locale: languageController.currentLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme, // Tema claro
        darkTheme: AppTheme.darkTheme, // Tema oscuro
        themeMode: themeController.themeMode,
        initialRoute: AuthRoutes.checkAuth,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
