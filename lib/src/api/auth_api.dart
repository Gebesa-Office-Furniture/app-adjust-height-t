import 'dart:async';
import 'dart:convert';
import 'package:controller/src/api/api_helper.dart';
import 'package:controller/src/api/token_manager.dart';
import 'package:controller/src/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Clase que gestiona las operaciones de autenticación a través de la API.
class AuthApi {
  /// URL base de la API, obtenida desde la configuración de la aplicación.
  static String baseUrl = AppConfig.apiBaseUrl;

  /// Registra un usuario en la aplicación.
  ///
  /// Parámetros:
  /// - `name`: Nombre del usuario.
  /// - `email`: Correo electrónico del usuario.
  /// - `password`: Contraseña del usuario.
  /// - `countryCode`: Código de país (opcional).
  /// - `phoneNumber`: Número de teléfono (opcional).
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password, {
    String? countryCode,
    String? phoneNumber,
  }) async {
    final url = Uri.parse('${baseUrl}auth/register');

    // Crear el cuerpo de la solicitud
    final Map<String, dynamic> requestBody = {
      'sName': name,
      'sEmail': email,
      'sPassword': password,
    };

    // Añadir los campos opcionales si no son nulos
    if (countryCode != null && countryCode.isNotEmpty) {
      requestBody['sLada'] = '+$countryCode';
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      requestBody['sPhoneNumber'] = phoneNumber;
    }

    // Debug print de la petición
    print('REGISTER REQUEST: ${json.encode(requestBody)}');

    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    return response;
  }

  /// Inicia sesión con las credenciales del usuario.
  ///
  /// Parámetros:
  /// - `email`: Correo electrónico del usuario.
  /// - `password`: Contraseña del usuario.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${baseUrl}auth/login');
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({'sEmail': email, 'sPassword': password}),
        headers: {'Content-Type': 'application/json'},
      ),
      isLoginRequest: true, // Indica que es una solicitud de inicio de sesión.
    );
    return response;
  }

  /// Actualiza el nombre del usuario autenticado.
  ///
  /// Parámetros:
  /// - `newName`: Nuevo nombre del usuario.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> updateUserName(String newName) async {
    final url = Uri.parse('$baseUrl/session/user/updateinfo');
    final prefs = await SharedPreferences.getInstance();

    // Verifica si el token es válido antes de continuar.
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }

    final token = prefs.getString(TokenManager.TOKEN_KEY);
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({'sName': newName}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  /// Registra el token de Firebase Cloud Messaging (FCM) para notificaciones push.
  ///
  /// Parámetros:
  /// - `fcmToken`: Token de FCM del dispositivo.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> registerFcmToken(String fcmToken) async {
    final url = Uri.parse('${baseUrl}session/user/suscribe');
    final prefs = await SharedPreferences.getInstance();

    // Verifica si el token es válido antes de continuar.
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }

    final token = prefs.getString(TokenManager.TOKEN_KEY);
    final response = await ApiHelper.handleRequest(
      http.post(
        url,
        body: json.encode({'sIdProvider': fcmToken}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ),
    );
    return response;
  }

  /// Elimina la cuenta del usuario autenticado.
  ///
  /// Retorna un mapa con la respuesta de la API.
  static Future<Map<String, dynamic>> deleteAccount() async {
    final url = Uri.parse('$baseUrl/session/user/delete');
    final prefs = await SharedPreferences.getInstance();

    // Verifica si el token es válido antes de continuar.
    bool validToken = await ApiHelper.validateToken();
    if (!validToken) {
      return {'success': false, 'type': 'SESSION_EXPIRED'};
    }

    final token = prefs.getString(TokenManager.TOKEN_KEY);
    final refreshToken = prefs.getString(TokenManager.REFRESH_TOKEN_KEY);

    // Extrae las últimas 5 letras del token de actualización.
    final deleteWord = refreshToken!.substring(refreshToken.length - 5);

    final response = await ApiHelper.handleRequest(
      http.delete(
        url,
        body: json.encode({
          'refreshToken': refreshToken,
          'deleteWord': deleteWord,
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
