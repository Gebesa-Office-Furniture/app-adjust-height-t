import 'package:controller/src/api/api_helper.dart';
import 'package:controller/src/api/token_manager.dart';
import 'package:controller/src/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Clase que gestiona las operaciones relacionadas con las estadísticas a través de la API.
class StatisticsApi {
  /// URL base de la API, obtenida desde la configuración de la aplicación.
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Obtiene las estadísticas del usuario para una fecha específica.
  ///
  /// Parámetros:
  /// - `date`: Fecha para la cual se quieren obtener las estadísticas, en formato de cadena.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> getStatistics(String date) async {
    final url = Uri.parse('${baseUrl}session/report/report');
    final prefs = await SharedPreferences.getInstance();

    // Verifica si el token es válido antes de realizar la solicitud.
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
