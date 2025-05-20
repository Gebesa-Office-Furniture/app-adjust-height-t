# Almacenamiento de UUID de Dispositivo

## Descripción General

Este documento describe la implementación del sistema de almacenamiento y reutilización del UUID de dispositivo en la aplicación. Esta funcionalidad permite guardar el identificador único del escritorio conectado y facilita la reconexión automática incluso cuando el dispositivo ya no está en memoria.

## Flujo de Funcionamiento

El sistema opera siguiendo este flujo:

1. **Conexión Inicial**: Cuando un escritorio se conecta, se guarda su UUID en SharedPreferences
2. **Inicio de Aplicación**: Al iniciar, se carga el UUID guardado
3. **Reconexión**: Si la conexión se pierde, se intenta reconectar usando el UUID almacenado
4. **Socket.IO**: El servicio de WebSocket utiliza el UUID guardado para establecer la conexión

## Componentes Principales

### Almacenamiento de UUID

El UUID se guarda en el método `setDevice()` del `DeskController`:

```dart
Future<void> setDevice(BluetoothDevice? newDevice) async {
  device = newDevice;
  if (device != null) {
    deviceName = device!.advName;
    // Save device UUID to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_uuid', device!.remoteId.str);
    print('Saved device UUID: ${device!.remoteId.str}');
  } else {
    deviceName = "";
    deviceReady = false;
  }
  notifyListeners();
}
```

### Carga de UUID guardado

El UUID se carga al inicializar el controlador mediante el método `loadSavedUUID()`:

```dart
/// Loads the saved device UUID from SharedPreferences
Future<void> loadSavedUUID() async {
  final prefs = await SharedPreferences.getInstance();
  final savedUUID = prefs.getString('device_uuid');
  if (savedUUID != null) {
    print('Loaded saved device UUID: $savedUUID');
  }
}
```

Este método se llama desde el constructor del `DeskController`:

```dart
DeskController() {
  loadSavedName();
  loadSavedUUID();
}
```

### Reconexión con UUID guardado

El método `reconnect()` usa el UUID guardado cuando no hay un dispositivo activo:

```dart
Future<void> reconnect() async {
  // Primero intenta reconectar al dispositivo existente
  if (device != null) {
    try {
      await device!.connect();
      print("Dispositivo reconectado exitosamente.");
      return;
    } catch (e) {
      print("Error al reconectar: $e");
    }
  }
  
  // Si no hay dispositivo o falló la reconexión, intenta usar el UUID guardado
  final prefs = await SharedPreferences.getInstance();
  final savedUUID = prefs.getString('device_uuid');
  if (savedUUID != null) {
    print('Intentando reconectar al dispositivo guardado: $savedUUID');
    // Lógica de reconexión usando el UUID guardado
  }
}
```

### Conexión de Socket.IO

El servicio de Socket.IO utiliza el UUID guardado cuando no se proporciona explícitamente:

```dart
void connect({String? sUUID}) async {
  // Si no se proporciona un UUID, intentar cargar el guardado
  String deviceUUID = sUUID ?? '';
  if (deviceUUID.isEmpty) {
    final prefs = await SharedPreferences.getInstance();
    deviceUUID = prefs.getString('device_uuid') ?? '';
    if (deviceUUID.isEmpty) {
      print('No se encontró UUID para conectar el socket');
      return;
    }
  }
  
  // Establecer la conexión de socket
  _socket = io.io(
    baseUrl,
    io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
  );
  
  _socket!..onConnect((_) {
    _connected = true;
    _socket!.emit('joinDesk', deviceUUID);
    debugPrint('🔌 Unido a $deviceUUID');
    notifyListeners();
  });
  
  // [...resto del código...]
}
```

## Ventajas del Sistema

1. **Reconexión automática**: Facilita la reconexión a escritorios previamente utilizados
2. **Persistencia entre sesiones**: Mantiene el identificador del dispositivo incluso después de cerrar la aplicación
3. **Experiencia mejorada**: El usuario puede reconectar rápidamente sin necesidad de buscar el dispositivo nuevamente
4. **Soporte para WebSockets**: Permite que las conexiones de Socket.IO se mantengan incluso si se pierde temporalmente la conexión Bluetooth

## Limitaciones

1. **Una sola conexión**: La aplicación está diseñada para manejar una sola conexión activa a la vez
2. **Almacenamiento local**: El UUID se almacena localmente en el dispositivo, no en la nube
3. **No hay histórico**: Solo se guarda el último dispositivo conectado, no un histórico de conexiones