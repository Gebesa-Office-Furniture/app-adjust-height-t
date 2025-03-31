import 'package:controller/src/api/api_helper.dart';
import 'package:controller/src/api/token_manager.dart';
import 'package:controller/src/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StatisticsApi {
  static String baseUrl = AppConfig.apiBaseUrl;

  //https://api.gebesa-app.com/session/report/report
  static Future<Map<String, dynamic>> getStatistics(String date) async {
    final url = Uri.parse('${baseUrl}session/report/report');
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
          'sTime': date,
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
