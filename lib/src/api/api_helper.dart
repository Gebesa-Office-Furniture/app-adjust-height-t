/// Utilidad para manejar peticiones HTTP y gestionar errores de API
/// 
/// Esta clase proporciona métodos auxiliares para realizar peticiones HTTP
/// y manejar las respuestas y errores de forma estandarizada.
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'token_manager.dart';

/// Clase auxiliar para gestionar peticiones HTTP
/// 
/// Proporciona métodos estáticos para realizar peticiones HTTP 
/// con manejo de errores y timeouts
class ApiHelper {
  /// Duración estándar del timeout para las peticiones
  static const Duration timeoutDuration = 
      Duration(seconds: 10);

  /// Maneja peticiones HTTP y sus posibles errores
  /// 
  /// [request] Petición HTTP a realizar
  /// [isLoginRequest] Indica si es una petición de inicio de sesión
  /// 
  /// Retorna un Map con:
  /// - success: bool indicando si la petición fue exitosa
  /// - data: datos de la respuesta si success es true
  /// - error: mensaje de error si success es false
  /// - statusCode: código de estado HTTP
  /// - type: tipo de error en caso de excepciones
  static Future<Map<String, dynamic>> handleRequest(
      Future<http.Response> request,
      {bool isLoginRequest = false}) async {
    try {
      final response = await request.timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': response.body,
          'statusCode': response.statusCode
        };
      } else {
        return {
          'success': false,
          'error': response.body,
          'statusCode': response.statusCode
        };
      }
    } on SocketException {
      // Maneja errores de conexión a internet
      return {
        'success': false,
        'type': const SocketException('No internet connection')
      };
    } on TimeoutException {
      // Maneja errores por timeout de la petición
      return {'success': false, 'type': TimeoutException('Request timed out')};
    } on FormatException {
      // Maneja errores de formato en la respuesta
      return {
        'success': false,
        'type': const FormatException('Invalid response format')
      };
    } catch (e) {
      // Maneja errores no específicos
      return {'success': false, 'type': UnsupportedError('Unsupported error')};
    }
  }

  /// Refresca el token de autenticación
  /// 
  /// Realiza una petición al endpoint de refresh token para obtener 
  /// nuevos tokens de acceso usando el refresh token almacenado.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await ApiHelper.refreshToken();
  /// if (result['success']) {
  ///   // Token refrescado exitosamente
  ///   print(result['data']);
  /// }
  /// ```
  /// 
  /// Returns:
  /// Map<String,dynamic> con:
  /// - success: bool - Éxito de la operación
  /// - data: String - Nuevos tokens en caso de éxito
  /// - error: String - Mensaje de error en caso de fallo
  /// - statusCode: int - Código de estado HTTP
  static Future<Map<String, dynamic>> refreshToken() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}auth/refreshToken');
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(TokenManager.REFRESH_TOKEN_KEY);
    Map<String, dynamic> data = {};
    
    // Realiza petición POST para refrescar token
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken'
      },
      body: json.encode({'refreshToken': refreshToken}),
    );

    // Procesa respuesta
    if (response.statusCode >= 200 && response.statusCode < 300) {
      data = {
        'success': true,
        'data': response.body,
        'statusCode': response.statusCode
      };
    } else {
      // Token expirado o inválido
      data = {
        'success': false,
        'error': response.body,
        'statusCode': response.statusCode
      };
    }
    //update token
    if (data['success']) {
      final token = json.decode(data['data'])['token']['result'];
      final tokenExpiry = DateTime.now().add(
          Duration(seconds: json.decode(data['data'])['token']['expiresIn']));

      await TokenManager.updateToken(token, tokenExpiry);
    }
    return data;
  }

  /// Valida el estado actual de los tokens
  /// 
  /// Verifica la expiración tanto del token de acceso como del refresh token.
  /// Si el token de acceso está expirado pero el refresh token es válido,
  /// intenta renovar automáticamente.
  ///
  /// Ejemplo:
  /// ```dart
  /// if (await ApiHelper.validateToken()) {
  ///   // Tokens válidos, continuar
  /// } else {
  ///   // Tokens inválidos, usuario desconectado
  /// }
  /// ```
  /// 
  /// Returns:
  /// - true: Tokens válidos o renovados exitosamente
  /// - false: No se pudo validar/renovar tokens
  static Future<bool> validateToken() async {
    final isTokenExpired = await TokenManager.isTokenExpired();
    final isRefreshTokenExpired = await TokenManager.isRefreshTokenExpired();
    if (isTokenExpired && isRefreshTokenExpired) {
      logout();
      return false;
    } else if (isTokenExpired && !isRefreshTokenExpired) {
      final response = await refreshToken();
      if (response['success']) {
        return true;
      } else {
        logout();
        return false;
      }
    } else {
      return true;
    }
  }

  /// Cierra la sesión del usuario
  /// 
  /// Realiza las siguientes acciones:
  /// 1. Limpia SharedPreferences
  /// 2. Cierra sesión en Firebase
  /// 3. Elimina tokens almacenados
  ///
  /// IMPORTANTE: Debe llamarse al cerrar sesión para limpiar datos sensibles
  ///
  /// Ejemplo:
  /// ```dart
  /// await ApiHelper.logout();
  /// // Navegar a pantalla login
  /// ```
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    //navigate to login screen
  }
}
