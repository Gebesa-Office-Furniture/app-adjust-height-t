import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'api_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_manager.dart';

class DeskApi {
  static String baseUrl = AppConfig.apiBaseUrl;

  //update memory desk
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

  //change name desk
  static Future<Map<String, dynamic>> changeNameDesk(String name) async {
    final url = Uri.parse('${baseUrl}session/user/name');
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
          'sName': name,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  //register or update desk device
  static Future<Map<String, dynamic>> registerDeskDevice(
      String deviceName, String deviceId, String status) async {
    final url = Uri.parse('${baseUrl}session/desk/conexion');
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
          'sDeskName': deviceName,
          'iStatus': status,
          'sUUID': deviceId,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  //method post https://api.gebesa-app.com/session/desk/movement send order and height
  static Future<Map<String, dynamic>> moveDeskToPosition(
      int order, double height, int idRoutine) async {
    final url = Uri.parse('${baseUrl}session/desk/movement');
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
          'iOrder': order,
          'dHeightInch': height,
          'iIdRoutine': idRoutine,
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
