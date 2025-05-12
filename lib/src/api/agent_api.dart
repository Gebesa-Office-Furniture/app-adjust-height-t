import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_helper.dart';
import 'token_manager.dart';

/// Clase para gestionar las operaciones API relacionadas con el agente de chat
class AgentApi {
  /// Verifica la disponibilidad del chat con el agente
  ///
  /// Realiza una petición al endpoint para verificar si el chat con el agente
  /// debe mostrarse o no en la aplicación
  ///
  /// Returns:
  /// - true: Si el agente debe mostrarse (statusCode 200)
  /// - false: Si el agente debe ocultarse (statusCode 201 u otros)
  static Future<bool> checkAgentAvailability() async {
    try {
      // Verifica que el token sea válido
      bool isValid = await ApiHelper.validateToken();
      if (!isValid) {
        return false;
      }

      // Construye la URL para la petición
      final url = Uri.parse('${AppConfig.apiBaseUrl}/status/check');

      // Realiza la petición GET al endpoint
      final request = http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Maneja la respuesta
      final response = await ApiHelper.handleRequest(request);

      // Si la petición fue exitosa y el statusCode es 200, el agente debe mostrarse
      return response['success'] && response['statusCode'] == 200;
    } catch (e) {
      // En caso de error, por defecto no mostrará el agente
      return false;
    }
  }
}
