import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Clase que maneja los errores y genera mensajes de error localizados.
class ErrorHandler {
  /// Obtiene un mensaje de error basado en el tipo de error proporcionado.
  ///
  /// Parámetros:
  /// - `error`: El error que ocurrió, puede ser de diferentes tipos (SocketException, TimeoutException, etc.).
  /// - `context`: El contexto de la aplicación, necesario para la localización de los mensajes.
  ///
  /// Retorna un mensaje localizado que describe el error.
  static String getErrorMessage(dynamic error, BuildContext context) {
    if (error is SocketException) {
      // Error de conexión de red.
      return AppLocalizations.of(context)!.socketException;
    } else if (error is TimeoutException) {
      // Error por tiempo de espera excedido.
      return AppLocalizations.of(context)!.timeOutException;
    } else if (error is FormatException) {
      // Error de formato incorrecto.
      return AppLocalizations.of(context)!.formatException;
    } else if (error == "SESSION_EXPIRED") {
      // Error de sesión expirada.
      return AppLocalizations.of(context)!.sessionExpired;
    } else {
      // Error desconocido.
      return AppLocalizations.of(context)!.unknownException;
    }
  }
}
