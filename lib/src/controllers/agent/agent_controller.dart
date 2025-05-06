import 'package:flutter/material.dart';
import '../../api/agent_api.dart';

/// Controlador para gestionar el estado y la disponibilidad del agente de chat
class AgentController with ChangeNotifier {
  bool _isAgentAvailable = false;
  bool _isLoading = true;

  /// Indica si el agente está disponible para mostrar en la aplicación
  bool get isAgentAvailable => _isAgentAvailable;

  /// Indica si se está cargando la disponibilidad del agente
  bool get isLoading => _isLoading;

  /// Constructor del controlador
  AgentController() {
    // Verifica la disponibilidad del agente al inicializar
    checkAgentAvailability();
  }

  /// Verifica la disponibilidad del agente consultando la API
  ///
  /// Actualiza el estado del controlador según la respuesta del servidor
  Future<void> checkAgentAvailability() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Llama al API para verificar disponibilidad
      final isAvailable = await AgentApi.checkAgentAvailability();
      
      _isAgentAvailable = isAvailable;
    } catch (e) {
      // En caso de error, establece como no disponible
      _isAgentAvailable = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}