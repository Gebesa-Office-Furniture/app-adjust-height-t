import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Color palette for Dark Theme
  static const Color _darkBackground = Color(0xFF002022);
  static const Color _darkPrimary = Color(0xFF0FB5C3);
  static const Color _darkText = Colors.white;
  static const Color _darkTextColor = Colors.white;

  static const Color _darkPopupSelected = Color(0xFF444444);

  // Color palette for Light Theme
  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF0FB5C3);
  static const Color _lightText = Colors.black;
  static const Color _lightTextColor = Color(0xFF00454A);

  //dark theme for statistics screen

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    cardColor: _darkPrimary.withOpacity(0.1),
    cardTheme: CardTheme(
      color: _darkPrimary.withOpacity(0.1),
      surfaceTintColor: _darkPrimary.withOpacity(0.5),
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackground,
    primaryColor: _darkPrimary,
    primaryColorLight: Colors.white.withOpacity(0.3),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: _customTextTheme(_darkTextColor),
    fontFamily: 'Airbnb',
    popupMenuTheme: const PopupMenuThemeData(
      color: _lightTextColor,
      textStyle: TextStyle(color: _darkText, fontFamily: 'Airbnb'),
    ),
    highlightColor: _darkPopupSelected,
    dialogTheme: const DialogTheme(
      backgroundColor: _darkBackground,
      titleTextStyle: TextStyle(
        color: _darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Airbnb',
      ),
      contentTextStyle: TextStyle(
        color: _darkText,
        fontSize: 16,
        fontFamily: 'Airbnb',
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      surfaceTintColor: _darkBackground,
      iconTheme: IconThemeData(color: _darkText),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: _darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Airbnb',
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.1),
      surfaceTintColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.all(_darkPrimary),
      thumbColor: WidgetStateProperty.all(Colors.white), // Color del botón
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(_darkPrimary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
              color: Colors.red, fontSize: 18, fontFamily: 'Airbnb'),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.cyan.withOpacity(0.3); // Color del splash
            }
            return null; // Usar el color predeterminado para otros estados
          },
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(_darkPrimary),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            color: _darkPrimary,
            fontSize: 18,
            fontFamily: 'Airbnb',
          ),
        ),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(_darkPrimary),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _darkPrimary,
    ),
    listTileTheme: const ListTileThemeData(textColor: _darkText),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontFamily: 'Airbnb',
      ),
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontFamily: 'Airbnb',
      ),
      filled: true,
      fillColor: _darkPrimary.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _darkPrimary,
        ),
      ),
    ),
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    cardColor: Colors.white,
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.2),
      surfaceTintColor: Colors.grey.withOpacity(0.1),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBackground,
    primaryColor: _lightPrimary,
    primaryColorLight: _lightPrimary.withOpacity(0.2),
    textTheme: _customTextTheme(_lightTextColor),
    fontFamily: 'Airbnb',
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.grey.withOpacity(0.1),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF002022)),
    popupMenuTheme: const PopupMenuThemeData(
      color: _lightBackground,
      textStyle: TextStyle(
        color: _lightTextColor,
        fontFamily: 'Airbnb',
      ),
    ),
    listTileTheme: const ListTileThemeData(textColor: _lightText),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _lightPrimary,
    ),
    highlightColor: _lightPrimary.withOpacity(0.2),
    dialogTheme: const DialogTheme(
      backgroundColor: _lightBackground,
      titleTextStyle: TextStyle(
        color: _lightText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Airbnb',
      ),
      contentTextStyle: TextStyle(
        color: _lightText,
        fontSize: 16,
        fontFamily: 'Airbnb',
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackground,
      surfaceTintColor: _lightBackground,
      iconTheme: IconThemeData(color: _lightText),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: _lightText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Airbnb',
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(_darkPrimary),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.all(Colors.grey.shade100),
      thumbColor: WidgetStateProperty.all(Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(_lightPrimary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Airbnb',
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.cyan.withOpacity(0.3); // Color del splash
            }
            return null; // Usar el color predeterminado para otros estados
          },
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(_lightPrimary),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            color: _lightPrimary,
            fontSize: 18,
            fontFamily: 'Airbnb',
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Colors.black.withOpacity(0.3),
        fontFamily: 'Airbnb',
      ),
      labelStyle: TextStyle(
        color: Colors.black.withOpacity(0.3),
        fontFamily: 'Airbnb',
      ),
      filled: true,
      fillColor: _darkPrimary.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _darkPrimary,
        ),
      ),
    ),
  );

  // TextTheme personalizado
  // Método para personalizar TextTheme con la fuente
  static TextTheme _customTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      displayMedium: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      displaySmall: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      headlineLarge: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      headlineMedium: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      headlineSmall: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      titleLarge: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      titleMedium: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      titleSmall: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      bodyLarge: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      bodyMedium: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      bodySmall: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      labelLarge: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      labelMedium: TextStyle(color: textColor, fontFamily: 'Airbnb'),
      labelSmall: TextStyle(color: textColor, fontFamily: 'Airbnb'),
    );
  }
}
