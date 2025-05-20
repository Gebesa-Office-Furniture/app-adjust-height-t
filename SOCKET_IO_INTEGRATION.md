# Proceso de Integración de Socket.IO para el Control de Mesas Ajustables

## Flujo Actual de Vinculación de un Desk

Cuando un usuario vincula una mesa (desk) a la aplicación, se sigue el siguiente proceso:

1. **Conexión Bluetooth**
   - La clase `BluetoothController` gestiona el estado del adaptador Bluetooth.
   - El usuario busca y selecciona un dispositivo Bluetooth (mesa) desde la interfaz.

2. **Configuración del Dispositivo**
   - `DeskController.setDevice()` establece el dispositivo seleccionado.
   - Se inicia la escucha del estado de conexión mediante `listenToConnectionState()`.
   
3. **Descubrimiento de Servicios**
   - Una vez conectado, se ejecuta `_discoverServices()` para encontrar los servicios BLE.
   - Se utiliza la configuración en `DeskServiceConfig` para identificar las características específicas.
   - Se buscan tres características importantes:
     - `targetCharacteristic`: Para enviar comandos a la mesa
     - `reportCharacteristic`: Para recibir datos de altura y estado
     - `deviceInfoCharacteristic`: Para obtener/modificar información del dispositivo

4. **Configuración de Notificaciones**
   - Se configura `_listenForNotifications()` para recibir actualizaciones de altura en tiempo real.
   - Se envía un comando inicial y se solicita el rango de altura.

5. **Registro en el Servidor**
   - Cuando se recibe información del rango de altura, se registra el dispositivo en el backend:
   ```dart
   await DeskApi.registerDeskDevice(
     deviceName ?? "Desk",
     device!.remoteId.str,
     "1", // Estado conectado
     minHeightMM: minHeightMM,
     maxHeightMM: maxHeightMM,
   );
   ```

6. **Control de la Mesa**
   - A través de `targetCharacteristic` se envían comandos para:
     - Subir/bajar la mesa (`moveUp()`, `moveDown()`)
     - Configurar posiciones de memoria (`setupMemory1/2/3()`)
     - Mover a posiciones específicas (`moveToHeight()`, `moveMemory1/2/3()`)

7. **Reporte de Movimientos**
   - Cuando la mesa se detiene (después de 5 segundos sin cambios), se reporta la nueva posición:
   ```dart
   await DeskApi.moveDeskToPosition(0, heightIN!, idRoutine)
   ```

## Implementación Actual de Socket.IO

El proyecto ya cuenta con un controlador básico de Socket.IO en `socket_io_controller.dart`:

```dart
class DeskSocketService extends ChangeNotifier {
  final DeskController desk;
  final String baseUrl = AppConfig.apiBaseUrl;

  io.Socket? _socket;
  bool _connected = false;

  bool get isConnected => _connected;

  DeskSocketService(this.desk);

  void connect({required int deskId}) {
    _socket = io.io(
      baseUrl,
      {
        'transports': ['websocket'],
        'autoConnect': false
      },
    );

    _socket!
      ..onConnect((_) {
        _connected = true;
        _socket!.emit('joinDesk', deskId);
        debugPrint('🔌 Conectado y unido a desk $deskId');
        notifyListeners();
      })
      ..onDisconnect((_) {
        _connected = false;
        debugPrint('🛑 Socket desconectado');
        notifyListeners();
      })
      ..onConnectError((e) => debugPrint('❗ connect error $e'))
      ..onError((e) => debugPrint('❗ socket error  $e'))
      ..on('desk:height', (data) {
        final target = data['targetMm'] as int;
        final cmdId = data['cmdId'] as int;
        debugPrint('📥 Orden: $target mm (cmd $cmdId)');

        desk.moveToHeight(target);
        _socket!.emit('desk:ack', {'cmdId': cmdId});
        debugPrint('📤 ACK enviado cmd $cmdId');
      })
      ..connect();
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
```

## Puntos de Integración para el Servidor Socket.IO

Para integrar completamente tu servidor Socket.IO, deberías considerar los siguientes puntos:

### 1. Inicialización del Servicio Socket.IO

- **Momento óptimo**: Después de un registro exitoso del dispositivo en el backend.
- **Ubicación en el código**: En `DeskController`, después de la línea 252-260 donde se registra el dispositivo.

```dart
// Ejemplo de integración en DeskController
if (await InternetConnection().hasInternetAccess && device != null) {
  await DeskApi.registerDeskDevice(
    deviceName ?? "Desk",
    device!.remoteId.str,
    "1", // Estado conectado
    minHeightMM: minHeightMM,
    maxHeightMM: maxHeightMM,
  ).then((response) {
    if (response['success']) {
      // Obtener ID del escritorio desde la respuesta
      final deskId = response['data']['iIdDesk'] ?? -1;
      if (deskId > 0) {
        // Iniciar conexión Socket.IO
        final socketService = DeskSocketService(this);
        socketService.connect(deskId: deskId);
      }
    }
  });
}
```

### 2. Eventos a Implementar en el Servidor

1. **Autenticación y Unión a Room**
   - `joinDesk`: Cuando un cliente se conecta y envía su ID de desk
   - Autenticación mediante token JWT

2. **Control Remoto de Altura**
   - `desk:height`: Para enviar comandos de altura desde el servidor
   - `desk:ack`: Para recibir confirmaciones del cliente

3. **Actualización de Estado**
   - `desk:status`: Para informar sobre cambios de estado (conectado/desconectado)
   - `desk:position`: Para reportar la posición actual de la mesa

4. **Memoria y Rutinas**
   - `desk:memory`: Para sincronizar posiciones de memoria
   - `desk:routine`: Para notificar sobre rutinas activas

### 3. Estructura de Servidor Socket.IO Recomendada

```javascript
// Ejemplo básico de estructura del servidor Socket.IO
const io = require('socket.io')(httpServer);
const jwt = require('jsonwebtoken');

// Autenticación de usuarios mediante middleware
io.use((socket, next) => {
  if (socket.handshake.query && socket.handshake.query.token) {
    jwt.verify(socket.handshake.query.token, 'SECRET_KEY', (err, decoded) => {
      if (err) return next(new Error('Authentication error'));
      socket.decoded = decoded;
      next();
    });
  } else {
    next(new Error('Authentication error'));
  }
});

io.on('connection', (socket) => {
  console.log('Cliente conectado', socket.id);
  
  // Cliente se une a una sala específica de escritorio
  socket.on('joinDesk', (deskId) => {
    socket.join(`desk_${deskId}`);
    console.log(`Cliente unido a desk_${deskId}`);
    
    // Informar al cliente que se ha unido correctamente
    socket.emit('desk:joined', { deskId });
  });
  
  // Escuchar actualizaciones de posición
  socket.on('desk:position', (data) => {
    const { deskId, height, memorySlot } = data;
    // Almacenar en base de datos
    // Notificar a otros clientes interesados
    socket.to(`desk_${deskId}_observers`).emit('desk:updated', data);
  });
  
  // Enviar comando de cambio de altura
  // Este evento sería utilizado por un panel de administración
  socket.on('admin:moveDesk', (data) => {
    const { deskId, targetHeight, cmdId } = data;
    io.to(`desk_${deskId}`).emit('desk:height', { 
      targetMm: targetHeight, 
      cmdId 
    });
  });
  
  // Recibir confirmación de comandos
  socket.on('desk:ack', (data) => {
    const { cmdId } = data;
    console.log(`Comando ${cmdId} ejecutado correctamente`);
    // Actualizar estado del comando en la base de datos
  });
  
  socket.on('disconnect', () => {
    console.log('Cliente desconectado', socket.id);
  });
});
```

### 4. Modificaciones Necesarias en el Cliente

1. **Inicialización en el Momento Adecuado**

Modificar la clase `DeskSocketService` para incluir la autenticación:

```dart
void connect({required int deskId}) {
  // Obtener token de autenticación
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(TokenManager.TOKEN_KEY);
  
  _socket = io.io(
    baseUrl,
    {
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': token}
    },
  );
  
  // Resto del código...
}
```

2. **Reportar Cambios de Posición**

Añadir en `_listenForNotifications()` o `_resetNoDataTimer()`:

```dart
// Después de que la mesa se detiene (estable)
if (_connected && heightIN! > 0) {
  _socket!.emit('desk:position', {
    'deskId': deskId,
    'height': heightIN,
    'heightMm': heightMM,
    'memorySlot': memorySlot
  });
}
```

3. **Manejar Eventos Adicionales**

```dart
_socket!
  // Eventos existentes...
  ..on('desk:joined', (data) {
    debugPrint('✅ Unido a sala de desk ${data['deskId']}');
  })
  ..on('desk:memory_sync', (data) {
    // Actualizar posiciones de memoria locales
    // desde el servidor
  })
  ..on('desk:routine_notification', (data) {
    // Mostrar notificación de rutina
  });
```

## Consideraciones de Diseño

1. **Robustez ante Desconexiones**
   - Implementar reconexión automática en caso de pérdida de conexión
   - Mantener una cola de cambios pendientes para sincronizar cuando se recupere la conexión

2. **Seguridad**
   - Autenticar todas las conexiones mediante tokens JWT
   - Validar los comandos entrantes para evitar movimientos peligrosos
   - Implementar throttling para evitar sobrecarga de comandos

3. **Eficiencia**
   - Limitar las actualizaciones de posición en tiempo real (considerar throttling)
   - Implementar compresión de datos si la cantidad de información es grande

4. **Escenarios de Uso**
   - Control desde múltiples dispositivos
   - Supervisión y análisis de uso
   - Integración con sistemas de recordatorios y rutinas

## Conclusión

La integración de Socket.IO en este sistema permite crear una experiencia en tiempo real para el control de mesas ajustables, habilitando funcionalidades como control remoto, sincronización entre dispositivos y recolección de análisis de uso.

La estructura actual del proyecto ya cuenta con los elementos básicos necesarios para esta integración, solo se requiere expandir la implementación del `DeskSocketService` y asegurar que se inicialice correctamente después del registro del dispositivo.