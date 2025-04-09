import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'api_helper.dart';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

/// Clase que gestiona las operaciones relacionadas con las rutinas a través de la API.
class RoutineApi {
  /// URL base de la API, obtenida desde la configuración de la aplicación.
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Crea o actualiza una rutina.
  ///
  /// Parámetros:
  /// - `id`: Identificador de la rutina.
  /// - `name`: Nombre de la rutina.
  /// - `duration`: Duración de la rutina en segundos.
  /// - `status`: Estado de la rutina.
  /// - `sedentarismo`: Nivel de sedentarismo asociado a la rutina.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> createUpdateRoutine(
    int id,
    String name,
    int duration,
    int status,
    int sedentarismo,
  ) async {
    final url = Uri.parse('${baseUrl}session/routine/routine');
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

  /// Inicia una rutina.
  ///
  /// Parámetros:
  /// - `idRoutine`: Identificador de la rutina a iniciar.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> startRoutine(int idRoutine) async {
    final url = Uri.parse('${baseUrl}session/routine/prepared/start');
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
        body: json.encode({"iId": idRoutine}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  /// Detiene una rutina en ejecución.
  ///
  /// Parámetros:
  /// - `idRoutine`: Identificador de la rutina a detener.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> stopRoutine(int idRoutine) async {
    final url = Uri.parse('${baseUrl}session/routine/prepared/stop');
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
