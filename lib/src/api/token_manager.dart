import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String TOKEN_KEY = 'token';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const String TOKEN_EXPIRY_KEY = 'token_expiry';
  static const String REFRESH_TOKEN_EXPIRY_KEY = 'refresh_token_expiry';

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

  //update token
  static Future<void> updateToken(String token, DateTime expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(TOKEN_EXPIRY_KEY, expiresIn.toIso8601String());
  }

  //update refresh token
  static Future<void> updateRefreshToken(
      String refreshToken, DateTime expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(REFRESH_TOKEN_KEY, refreshToken);
    await prefs.setString(
        REFRESH_TOKEN_EXPIRY_KEY, expiresIn.toIso8601String());
  }

  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(TOKEN_EXPIRY_KEY);
    if (expiryString == null) return true;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  static Future<bool> isRefreshTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(REFRESH_TOKEN_EXPIRY_KEY);
    if (expiryString == null) return true;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }
}
