import 'dart:convert';

import 'package:controller/src/api/api_helper.dart';
import 'package:controller/src/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'token_manager.dart';

class UserApi {
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Get user data
  static Future<Map<String, dynamic>> getUserData() async {
    final url = Uri.parse('${baseUrl}session/user/settings');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final response = await ApiHelper.handleRequest(
      http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  //update user data session/user/updateadditionalinfo
  static Future<Map<String, dynamic>> updateUserData(
      int measurementSystem, double height, double weight) async {
    final url = Uri.parse('$baseUrl/session/user/updateadditionalinfo');
    final prefs = await SharedPreferences.getInstance();
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({
          'iMeasureType': measurementSystem,
          'dHeightM': height,
          'dWeightKG': weight
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
