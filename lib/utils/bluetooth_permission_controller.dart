import 'package:permission_handler/permission_handler.dart';

class BluetoothPermissionController {
  /// Verifica si los permisos de Bluetooth están concedidos
  Future<bool> checkPermissions() async {
    // Verifica permisos esenciales
    var bluetoothScanStatus = await Permission.bluetoothScan.status;
    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;

    return bluetoothScanStatus.isGranted && bluetoothConnectStatus.isGranted;
  }

  /// Solicita permisos de Bluetooth al usuario
  Future<bool> requestPermissions() async {
    // Solicita permisos necesarios
    var statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();

    // Revisa si todos los permisos fueron concedidos
    return statuses.values.every((status) => status.isGranted);
  }

  /// Maneja la solicitud de permisos (con mensajes de error si es necesario)
  Future<void> handlePermissions() async {
    bool isGranted = await checkPermissions();

    if (!isGranted) {
      isGranted = await requestPermissions();
      if (!isGranted) {
        // Muestra un mensaje al usuario indicando que debe habilitar permisos manualmente
        openAppSettings();
        throw Exception(
            "Los permisos de Bluetooth son necesarios para continuar.");
      }
    }
  }
}
