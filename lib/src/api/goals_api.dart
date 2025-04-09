import 'package:controller/src/api/token_manager.dart';
import 'package:controller/src/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Clase que gestiona las operaciones relacionadas con las metas del usuario a través de la API.
class GoalsApi {
  /// URL base de la API, obtenida desde la configuración de la aplicación.
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Guarda una posición de memoria del escritorio.
  ///
  /// Parámetros:
  /// - `memoryPosition`: Posición de memoria que se quiere guardar.
  /// - `height`: Altura del escritorio en pulgadas.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> saveMemoryDesk(
      int memoryPosition, double height) async {
    final url = Uri.parse('${baseUrl}session/user/memory');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TokenManager.TOKEN_KEY);

    // Verifica si el token es válido antes de realizar la solicitud.
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

  /// Establece las metas de tiempo y calorías del usuario.
  ///
  /// Parámetros:
  /// - `standingSeconds`: Tiempo en segundos de permanencia de pie.
  /// - `sittingSeconds`: Tiempo en segundos de permanencia sentado.
  /// - `calories`: Cantidad de calorías que se desean quemar.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> setGoals(
      int standingSeconds, int sittingSeconds, int calories) async {
    final url = Uri.parse('${baseUrl}session/user/setgoal');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TokenManager.TOKEN_KEY);

    // Verifica si el token es válido antes de realizar la solicitud.
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

  /// Obtiene las metas de tiempo y calorías del usuario.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> getGoals() async {
    final url = Uri.parse('${baseUrl}session/user/getgoal');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TokenManager.TOKEN_KEY);

    // Verifica si el token es válido antes de realizar la solicitud.
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
