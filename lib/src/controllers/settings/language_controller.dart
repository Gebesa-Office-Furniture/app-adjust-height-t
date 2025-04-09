import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';

class LanguageController with ChangeNotifier {
  Locale _currentLocale = Platform.localeName.contains('es')
      ? const Locale('es')
      : const Locale('en');

  Locale get currentLocale => _currentLocale;

  // Constructor que carga el idioma guardado
  LanguageController() {
    _loadSavedLanguage();
  }

  Future<void> setLanguage(int language) async {
    final prefs = await SharedPreferences.getInstance();

    var height = prefs.getDouble('height') ?? 0;
    var weight = prefs.getDouble('weight') ?? 0;
    var unit = prefs.getInt('measurementUnit') ?? 0;
    var noti = prefs.getBool('sedentaryNotification') ?? false;
    var theme = prefs.getInt('themeMode') ?? 1;

    prefs.setInt('language', theme);

    await UserApi.updateUserData(unit, height, weight, noti, language, theme);
  }

  // Cargar el idioma guardado en SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    int? langCode = prefs.getInt('language') ?? 1;
    _currentLocale = Locale(langCode == 1 ? 'es' : 'en');
    notifyListeners(); // Notifica para que la UI se actualice

    await setLanguage(langCode);
  }

  // Cambiar el idioma y guardar en SharedPreferences
  Future<void> changeLanguage(String langCode) async {
    _currentLocale = Locale(langCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
  }
}
