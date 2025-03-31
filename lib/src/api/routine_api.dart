import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'api_helper.dart';
import 'package:http/http.dart' as http;

import 'token_manager.dart';

class RoutineApi {
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Register a user
  // static Future<Map<String, dynamic>> registerUser(
  //   String name,
  //   String email,
  //   String password,
  // ) async {
  //   final url = Uri.parse('${baseUrl}auth/register');
  //   final response = await ApiHelper.handleRequest(
  //     http.post(
  //       url,
  //       body: json
  //           .encode({'sName': name, 'sEmail': email, 'sPassword': password}),
  //       headers: {'Content-Type': 'application/json'},
  //     ),
  //   );
  //   return response;
  // }

  //post create routine https://api.gebesa-app.com/session/routine/routine
  static Future<Map<String, dynamic>> createUpdateRoutine(
    int id,
    String name,
    int duration,
    int status,
    int sedentarismo,
  ) async {
    final url = Uri.parse('${baseUrl}session/routine/routine');
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
          "iId": id,
          "iDurationSeconds": duration,
          "iStatus": status,
          "iSedentarismo": sedentarismo,
          "sRoutineName": name
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  //start routine post https://api.gebesa-app.com/session/routine/prepared/start
  static Future<Map<String, dynamic>> startRoutine(int idRoutine) async {
    final url = Uri.parse('${baseUrl}session/routine/prepared/start');
    final prefs = await SharedPreferences.getInstance();
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({"iId": idRoutine}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  //stop routine post https://api.gebesa-app.com/session/routine/prepared/stop
  static Future<Map<String, dynamic>> stopRoutine(int idRoutine) async {
    final url = Uri.parse('${baseUrl}session/routine/prepared/stop');
    final prefs = await SharedPreferences.getInstance();
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({"iId": idRoutine}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }
}
