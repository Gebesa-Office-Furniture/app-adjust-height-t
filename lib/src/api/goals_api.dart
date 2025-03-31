import 'package:controller/src/api/token_manager.dart';
import 'package:controller/src/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoalsApi {
  static String baseUrl = AppConfig.apiBaseUrl;

  static Future<Map<String, dynamic>> saveMemoryDesk(
      int memoryPosition, double height) async {
    final url = Uri.parse('${baseUrl}session/user/memory');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({
          'iOrder': memoryPosition,
          'dHeightInch': height,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  static Future<Map<String, dynamic>> setGoals(
      int standingSeconds, int sittingSeconds, int calories) async {
    final url = Uri.parse('${baseUrl}session/user/setgoal');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({
          "iStandingTimeSeconds": standingSeconds,
          "iSittingTimeSeconds": sittingSeconds,
          "iCaloriesToBurn": calories
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  static Future<Map<String, dynamic>> getGoals() async {
    final url = Uri.parse('${baseUrl}session/user/getgoal');
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
}
