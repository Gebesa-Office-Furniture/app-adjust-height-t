import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  // Clave para almacenar la preferencia del tema
  static const String _themePreferenceKey = 'theme_preference';

  // Estado inicial del tema
  ThemeMode _themeMode = ThemeMode.system;

  // Obtener el estado actual del tema
  ThemeMode get themeMode => _themeMode;

  // Constructor
  ThemeController() {
    _loadThemeFromPreferences(); // Cargar el tema al iniciar
  }

  // Método para cambiar entre temas (claro y oscuro)
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveThemeToPreferences(); // Guardar preferencia del tema
    notifyListeners(); // Notificar a los listeners
  }

  // Método para usar el tema del sistema
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _saveThemeToPreferences(); // Guardar la preferencia del tema
    notifyListeners();
  }

  // Cargar el tema almacenado en SharedPreferences
  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themePreferenceKey);

    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.dark;
    }

    notifyListeners(); // Notificar a los listeners para aplicar el tema
  }

  // Guardar el tema en SharedPreferences
  Future<void> _saveThemeToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String themeValue;

    if (_themeMode == ThemeMode.light) {
      themeValue = 'light';
    } else if (_themeMode == ThemeMode.dark) {
      themeValue = 'dark';
    } else {
      themeValue = 'system';
    }

    await prefs.setString(_themePreferenceKey, themeValue);
  }
}
