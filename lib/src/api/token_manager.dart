import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase que gestiona los tokens de autenticación y sus operaciones asociadas.
class TokenManager {
  /// Claves para el almacenamiento de los tokens en SharedPreferences.
  static const String TOKEN_KEY = 'token';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const String TOKEN_EXPIRY_KEY = 'token_expiry';
  static const String REFRESH_TOKEN_EXPIRY_KEY = 'refresh_token_expiry';

  /// Guarda el token de acceso y el token de actualización, junto con sus fechas de expiración.
  ///
  /// Parámetros:
  /// - `token`: Token de acceso.
  /// - `refreshToken`: Token de actualización.
  /// - `tokenExpiry`: Fecha de expiración del token de acceso.
  /// - `refreshTokenExpiry`: Fecha de expiración del token de actualización.
  static Future<void> saveTokens({
    required String token,
    required String refreshToken,
    required DateTime tokenExpiry,
    required DateTime refreshTokenExpiry,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(REFRESH_TOKEN_KEY, refreshToken);
    await prefs.setString(TOKEN_EXPIRY_KEY, tokenExpiry.toIso8601String());
    await prefs.setString(
        REFRESH_TOKEN_EXPIRY_KEY, refreshTokenExpiry.toIso8601String());
  }

  /// Actualiza el token de acceso y su fecha de expiración.
  ///
  /// Parámetros:
  /// - `token`: Nuevo token de acceso.
  /// - `expiresIn`: Fecha de expiración del nuevo token.
  static Future<void> updateToken(String token, DateTime expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(TOKEN_EXPIRY_KEY, expiresIn.toIso8601String());
  }

  /// Actualiza el token de actualización y su fecha de expiración.
  ///
  /// Parámetros:
  /// - `refreshToken`: Nuevo token de actualización.
  /// - `expiresIn`: Fecha de expiración del nuevo token de actualización.
  static Future<void> updateRefreshToken(
      String refreshToken, DateTime expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(REFRESH_TOKEN_KEY, refreshToken);
    await prefs.setString(
        REFRESH_TOKEN_EXPIRY_KEY, expiresIn.toIso8601String());
  }

  /// Verifica si el token de acceso ha expirado.
  ///
  /// Retorna `true` si el token ha expirado o no existe, de lo contrario `false`.
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(TOKEN_EXPIRY_KEY);
    if (expiryString == null) return true;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  /// Verifica si el token de actualización ha expirado.
  ///
  /// Retorna `true` si el token de actualización ha expirado o no existe, de lo contrario `false`.
  static Future<bool> isRefreshTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(REFRESH_TOKEN_EXPIRY_KEY);
    if (expiryString == null) return true;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  /// Cierra la sesión del usuario, limpiando los tokens almacenados y cerrando sesión en Firebase.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }
}
