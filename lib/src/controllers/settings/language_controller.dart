import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController with ChangeNotifier {
  Locale _currentLocale = Platform.localeName.contains('es')
      ? const Locale('es')
      : const Locale('en');

  Locale get currentLocale => _currentLocale;

  // Constructor que carga el idioma guardado
  LanguageController() {
    _loadSavedLanguage();
  }

  // Cargar el idioma guardado en SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language_code');
    if (langCode != null) {
      _currentLocale = Locale(langCode);
    }
    notifyListeners(); // Notifica para que la UI se actualice
  }

  // Cambiar el idioma y guardar en SharedPreferences
  Future<void> changeLanguage(String langCode) async {
    _currentLocale = Locale(langCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
  }
}
