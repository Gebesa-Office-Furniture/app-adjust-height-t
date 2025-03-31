import 'dart:async';
import 'dart:convert';
import 'package:controller/src/api/api_helper.dart';
import 'package:controller/src/api/token_manager.dart';
import 'package:controller/src/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Register a user
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('${baseUrl}auth/register');
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json
            .encode({'sName': name, 'sEmail': email, 'sPassword': password}),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    return response;
  }

  /// Log in
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${baseUrl}auth/login');
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({'sEmail': email, 'sPassword': password}),
        headers: {'Content-Type': 'application/json'},
      ),
      isLoginRequest: true,
    );
    return response;
  }

  /// Update the user's name
  static Future<Map<String, dynamic>> updateUserName(String newName) async {
    final url = Uri.parse('$baseUrl/session/user/updateinfo');
    final prefs = await SharedPreferences.getInstance();
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({'sName': newName}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  //register FCM token https://api.gebesa-app.com/session/user/suscribe
  static Future<Map<String, dynamic>> registerFcmToken(String fcmToken) async {
    final url = Uri.parse('${baseUrl}session/user/suscribe');
    final prefs = await SharedPreferences.getInstance();
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({'sIdProvider': fcmToken}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  //delete account https://api.gebesa-app.com/session/user/delete
  static Future<Map<String, dynamic>> deleteAccount() async {
    final url = Uri.parse('$baseUrl/session/user/delete');
    final prefs = await SharedPreferences.getInstance();
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final token = prefs.getString(TokenManager.TOKEN_KEY);

    final refreshToken = prefs.getString(TokenManager.REFRESH_TOKEN_KEY);
    //last 5 letters of refresh token
    final deleteWord = refreshToken!.substring(refreshToken.length - 5);

    final response = await ApiHelper.handleRequest(
      http.delete(
        url,
        body: json.encode({
          'refreshToken': refreshToken,
          'deleteWord': deleteWord,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }
}
