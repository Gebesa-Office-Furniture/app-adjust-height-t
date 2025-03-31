import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  /// Mostrar un toast de éxito
  static void showSuccess(BuildContext context, String message,
      {String? description,
      Alignment alignment = Alignment.bottomCenter,
      Duration? duration = const Duration(seconds: 2)}) {
    _showToast(
      context: context,
      message: message,
      type: ToastificationType.success,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      alignment: alignment,
      duration: duration,
    );
  }

  /// Mostrar un toast de información
  static void showInfo(BuildContext context, String message,
      {String? description,
      Alignment alignment = Alignment.bottomCenter,
      Duration? duration = const Duration(seconds: 2)}) {
    _showToast(
      context: context,
      message: message,
      type: ToastificationType.info,
      backgroundColor: Colors.grey[800]!,
      textColor: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      alignment: alignment,
      duration: duration,
    );
  }

  /// Mostrar un toast de error
  static void showError(BuildContext context, String message,
      {String? description, Alignment alignment = Alignment.bottomCenter}) {
    _showToast(
      context: context,
      message: message,
      type: ToastificationType.error,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      alignment: alignment,
    );
  }

  /// Método genérico para mostrar un toast
  static void _showToast({
    required BuildContext context,
    required String message,
    String? description,
    required ToastificationType type,
    required Color backgroundColor,
    required Color textColor,
    required Icon icon,
    Alignment alignment = Alignment.bottomCenter,
    Duration? duration = const Duration(seconds: 2),
  }) {
    toastification.show(
      context: context,
      type: type,
      alignment: alignment,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      title: Text(
        message,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      description: description != null
          ? Text(
              description,
              style: TextStyle(color: textColor),
            )
          : null,
      backgroundColor: backgroundColor,
      icon: icon,
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
      showIcon: true,
      closeOnClick: true,
    );
  }
}
