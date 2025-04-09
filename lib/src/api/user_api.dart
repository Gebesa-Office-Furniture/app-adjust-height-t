import 'dart:convert';
import 'package:controller/src/api/api_helper.dart';
import 'package:controller/src/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'token_manager.dart';

/// Clase que gestiona las operaciones relacionadas con la información del usuario a través de la API.
class UserApi {
  /// URL base de la API, obtenida desde la configuración de la aplicación.
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Obtiene los datos del usuario.
  ///
  /// Retorna un mapa con la respuesta de la API que contiene los datos del usuario.
  static Future<Map<String, dynamic>> getUserData() async {
    final url = Uri.parse('${baseUrl}session/user/settings');
    final prefs = await SharedPreferences.getInstance();

    // Verifica si el token es válido antes de realizar la solicitud.
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

  /// Actualiza los datos adicionales del usuario, como sistema de medición, altura y peso.
  ///
  /// Parámetros:
  /// - `measurementSystem`: Sistema de medición (ej. 1 para métrico, 2 para imperial).
  /// - `height`: Altura del usuario.
  /// - `weight`: Peso del usuario.
  /// -
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> updateUserData(
      int measurementSystem,
      double height,
      double weight,
      bool sedentaryNotification,
      int language,
      int themeMode) async {
    final url = Uri.parse('$baseUrl/session/user/updateadditionalinfo');
    final prefs = await SharedPreferences.getInstance();

    // Verifica si el token es válido antes de realizar la solicitud.
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
          'dWeightKG': weight,
          'bSedentaryNotification': sedentaryNotification,
          'iIdLanguage': language,
          'iViewMode': themeMode,
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
