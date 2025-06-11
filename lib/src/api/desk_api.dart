import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'api_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

/// Clase que gestiona las operaciones relacionadas con el control del escritorio a través de la API.
class DeskApi {
  /// URL base de la API, obtenida desde la configuración de la aplicación.
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Guarda la posición de memoria del escritorio.
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

  /// Cambia el nombre del escritorio.
  ///
  /// Parámetros:
  /// - `name`: Nuevo nombre para el escritorio.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> changeNameDesk(String name) async {
    final url = Uri.parse('${baseUrl}session/user/name');
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

  /// Registra o actualiza la conexión del dispositivo de escritorio.
  ///
  /// Parámetros:
  /// - `deviceName`: Nombre del dispositivo.
  /// - `deviceId`: Identificador único del dispositivo.
  /// - `status`: Estado del dispositivo.
  /// - `minHeightMM`: (Opcional) Altura mínima del escritorio en milímetros.
  /// - `maxHeightMM`: (Opcional) Altura máxima del escritorio en milímetros.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> registerDeskDevice(
      String deviceName, String deviceId, String status,
      {double? minHeightMM, double? maxHeightMM}) async {
    final url = Uri.parse('${baseUrl}session/desk/conexion');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TokenManager.TOKEN_KEY);

    // Verifica si el token es válido antes de realizar la solicitud.
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }

    final Map<String, dynamic> requestBody = {
      'sDeskName': deviceName,
      'iStatus': status,
      'sUUID': deviceId,
    };
    
    // Añadir límites de altura si están disponibles
    if (minHeightMM != null) {
      requestBody['dMinHeightMm'] = minHeightMM;
    }
    if (maxHeightMM != null) {
      requestBody['dMaxHeightMm'] = maxHeightMM;
    }

    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  /// Mueve el escritorio a una posición específica.
  ///
  /// Parámetros:
  /// - `order`: Orden de la posición.
  /// - `height`: Altura del escritorio en pulgadas.
  /// - `idRoutine`: Identificador de la rutina relacionada.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> moveDeskToPosition(
      int order, double height, int idRoutine) async {
    final url = Uri.parse('${baseUrl}session/desk/movement');
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

  static Future<Map<String, dynamic>> setNewUUID(String sName, String newUUID, double minHeightMM, double maxHeightMM) async{
    final url = Uri.parse('${baseUrl}desk/changeUUID');
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
          'sName':sName,
          'sNewUUID': newUUID,
          'dMinHeightMm': minHeightMM,
          'dMaxHeightMm': maxHeightMM,
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
