import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';

class ThemeController extends ChangeNotifier {
  // Clave para almacenar la preferencia del tema

  // Estado inicial del tema
  ThemeMode _themeMode = ThemeMode.system;

  // Obtener el estado actual del tema
  ThemeMode get themeMode => _themeMode;

  // Constructor
  ThemeController() {
    _loadThemeFromPreferences(); // Cargar el tema al iniciar
  }

  Future<void> setTheme(int theme) async {
    final prefs = await SharedPreferences.getInstance();

    var height = prefs.getDouble('height') ?? 0;
    var weight = prefs.getDouble('weight') ?? 0;
    var language = prefs.getInt('language') ?? 1;
    var unit = prefs.getInt('measurementUnit') ?? 0;
    var noti = prefs.getBool('sedentaryNotification') ?? false;

    prefs.setInt('themeMode', theme);

    await UserApi.updateUserData(unit, height, weight, noti, language, theme);
  }

  // Método para cambiar entre temas (claro y oscuro)
  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notificar a los listeners
    await setTheme(_themeMode == ThemeMode.dark ? 2 : 1);
  }

  // Método para usar el tema del sistema
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  // Cargar el tema almacenado en SharedPreferences
  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getInt('themeMode') ?? 1;

    if (theme == 1) {
      _themeMode = ThemeMode.light;
    } else if (theme == 2) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners(); // Notificar a los listeners para aplicar el tema
  }
}
