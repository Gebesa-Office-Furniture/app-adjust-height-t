# **📌 Documentación de la App Gebesa Desk Controller**

## **📖 Descripción del Proyecto**  
Aplicación Flutter para controlar y gestionar escritorios inteligentes con conectividad **Bluetooth**. La aplicación ofrece control de altura, gestión de rutinas y estadísticas de uso.  

---

## **🚀 Funciones Principales**

### 1. **Autenticación**
- Registro y acceso de usuarios  
- Integración con Google Sign-In  
- Integración con Apple Sign-In  
- Restablecimiento de contraseña  

### 2. **Control del Escritorio**
- Conexión Bluetooth con escritorios inteligentes  
- Controles de ajuste de altura  
- Configuración de posiciones de memoria (3 posiciones)  
- Seguimiento de altura en tiempo real  
- Conversión de unidades (Imperial/Métrico)  

### 3. **Rutinas**
- Crear rutinas personalizadas para el escritorio  
- Cambios de posición basados en temporizador  
- Seguimiento de calorías quemadas  
- Monitoreo de actividad (tiempo sentado/de pie)  

### 4. **Estadísticas**
- Seguimiento de actividad diaria  
- Registro de calorías quemadas  
- Posiciones de memoria más utilizadas  
- Tiempo dedicado sentado/de pie  

### 5. **Configuraciones**
- Personalización del tema (modo Claro/Oscuro)  
- Selección de idioma (Inglés/Español)  
- Unidades de medición (Métrico/Imperial)  
- Notificaciones push  
- Gestión del perfil  

---

## **🛠 Requisitos del Sistema**
- **Flutter**: `3.24.3`  
- **Xcode**: `15.0 (15A240d)`  
- **Android Studio**: `Android Studio Iguana | 2023.2.1 Patch 1`  
- **Dart SDK**: `3.x.x`  
- **Plataformas soportadas**:  
  - **iOS**: `12.0+`  
  - **Android**: `8.0+ (API 26+)`  
  - **Web**: Funcionalidad limitada  

---

## **⚙️ Instalación y Configuración**
### **1️⃣ Instalar dependencias**
Ejecuta en la terminal:  
```sh
flutter pub get
```

### **2️⃣ Configurar Firebase**
Si no existen, asegúrate de agregar el archivo `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) en sus respectivas carpetas.  

---

## **🌐 Localización (l10n)**
La aplicación utiliza el sistema de localización de Flutter para soportar múltiples idiomas. Los archivos de traducción se encuentran en la carpeta `lib/l10n` con extensión `.arb`.

### Generación de Archivos de Localización
Después de modificar cualquier archivo `.arb` en la carpeta `lib/l10n`, es necesario ejecutar el siguiente comando para generar los archivos de traducción:
```sh
flutter gen-l10n
```
Este comando generará las clases necesarias para usar los textos traducidos en la aplicación.

---

## **📡 Arquitectura Técnica**

### **Controladores**
- **AuthController:** Maneja autenticación y sesiones  
- **BluetoothController:** Administra conexiones BLE  
- **DeskController:** Controla operaciones del escritorio  
- **RoutineController:** Maneja rutinas y temporizadores  
- **StatisticsController:** Maneja seguimiento de actividad  
- **ThemeController:** Controla la configuración del tema  
- **MeasurementController:** Gestiona conversiones de unidades  

### **Integración con API**
- **AuthApi:** Autenticación  
- **UserApi:** Gestión de datos del usuario  
- **RoutineApi:** Gestión de rutinas  
- **StatisticsApi:** Seguimiento de estadísticas  
- **GoalsApi:** Gestión de metas del usuario  

### **Persistencia de Datos**
- **SharedPreferences:** Almacenamiento local  
- **Firebase:** Backend  
- **Autenticación basada en tokens**  

---

## **📦 Dependencias**
```yaml
dependencies:
  flutter_blue_plus: ^1.x.x  # Conectividad Bluetooth
  firebase_core: ^2.x.x      # Integración con Firebase
  firebase_auth: ^4.x.x      # Autenticación
  google_sign_in: ^6.x.x     # Google Sign-In
  provider: ^6.x.x           # Gestión de estado
  shared_preferences: ^2.x.x # Almacenamiento local
  http: ^0.13.x              # Solicitudes API
  toastification: ^1.x.x     # Notificaciones toast
```

---

## **🔧 Herramientas para Analizar BLE**
Si necesitas depurar la conexión Bluetooth, puedes usar estas herramientas:
- 📲 **[nRF Connect](https://play.google.com/store/apps/details?id=no.nordicsemi.android.mcp&hl=es&pli=1)** (iOS/Android)
- 💻 **[LightBlue](https://apps.apple.com/us/app/lightblue/id557428110)** (iOS)
- 📡 **[Bluetooth Scanner](https://play.google.com/store/apps/details?id=com.macdom.ble.blescanner&hl=es&pli=1)** (Android)

---

# Documentación del Controlador de Escritorio Bluetooth BLE

## Descripción General

Este proyecto implementa un controlador para un escritorio ajustable en altura que utiliza tecnología Bluetooth Low Energy (BLE) para la comunicación. El controlador permite ajustar la altura del escritorio, guardar posiciones en memoria, monitorear la altura actual y personalizar el nombre del dispositivo.

## Conexión Bluetooth BLE

La conexión con el dispositivo se realiza mediante la biblioteca `flutter_blue_plus`. El proceso de conexión incluye:

1. **Descubrimiento del dispositivo**: Se buscan dispositivos BLE cercanos.
2. **Establecimiento de conexión**: Se conecta al dispositivo seleccionado.
3. **Descubrimiento de servicios**: Se identifican los servicios disponibles en el dispositivo.
4. **Identificación de características**: Se localizan las características específicas para controlar el escritorio.

```dart
Future<void> _discoverServices(BuildContext context) async {
  isDiscoveringServices = true;
  notifyListeners();

  final discoveredServices = await device!.discoverServices();
  // Identificación de servicios y características compatibles
  // ...
}
```

## Comunicación con el Dispositivo

La comunicación se realiza mediante el envío de comandos específicos a través de características Bluetooth. El dispositivo utiliza tres características principales:

1. **targetCharacteristic**: Para enviar comandos de movimiento.
2. **reportCharacteristic**: Para recibir notificaciones sobre el estado actual.
3. **deviceInfoCharacteristic**: Para configurar información del dispositivo.

### Control de Movimiento

#### Mover Hacia Arriba

```dart
void moveUp() {
  final data = [0xF1, 0xF1, 0x01, 0x00, 0x01, 0x7E];
  targetCharacteristic!.write(data, withoutResponse: true);
}
```

El comando `[0xF1, 0xF1, 0x01, 0x00, 0x01, 0x7E]` indica al escritorio que debe moverse hacia arriba. Este comando se envía repetidamente mientras se mantiene presionado el botón correspondiente.

#### Mover Hacia Abajo

```dart
void moveDown() {
  final data = [0xF1, 0xF1, 0x02, 0x00, 0x02, 0x7E];
  targetCharacteristic!.write(data, withoutResponse: true);
}
```

Similar al movimiento hacia arriba, este comando indica al escritorio que debe moverse hacia abajo.

#### Mover a una Altura Específica

```dart
void moveToHeight(int mm) async {
  if (targetCharacteristic != null) {
    // Convertir la altura deseada a formato hexadecimal
    String hexStr = mm.toRadixString(16).padLeft(4, '0');
    List<int> bytes = [];
    for (int i = 0; i < hexStr.length; i += 2) {
      bytes.add(int.parse(hexStr.substring(i, i + 2), radix: 16));
    }
    
    // Generar el comando completo
    List<int> command = periferial(bytes);
    
    // Enviar el comando
    await targetCharacteristic!.write(command, withoutResponse: true, allowLongWrite: false);
  }
}
```

Este método permite mover el escritorio a una altura específica en milímetros. El proceso incluye:
1. Convertir la altura a formato hexadecimal
2. Generar el comando con el formato adecuado
3. Enviar el comando al dispositivo

### Monitoreo de Altura

Para recibir actualizaciones sobre la altura actual del escritorio, se configura una suscripción a las notificaciones del dispositivo:

```dart
Future<void> _listenForNotifications(BuildContext context) async {
  if (reportCharacteristic != null) {
    await reportCharacteristic!.setNotifyValue(true);
    reportCharacteristic!.onValueReceived.listen((event) async {
      // Procesar los datos recibidos
      // ...
      
      // Extraer la altura actual
      final dataH = event[4];
      final dataL = event[5];
      final hex = dataH.toRadixString(16).padLeft(2, '0') + 
                 dataL.toRadixString(16).padLeft(2, '0');
      final decimal = int.parse(hex, radix: 16);
      
      // Actualizar la altura actual
      heightIN = decimal / 10;
      heightMM = inchesToMm(heightIN!);
      
      // Calcular el progreso
      progress = calculateProgressPercentage(heightIN!, minHeight, maxHeight);
      
      notifyListeners();
    });
  }
}
```

Este método:
1. Activa las notificaciones en la característica de reporte
2. Configura un listener para procesar los datos recibidos
3. Extrae la información de altura de los datos
4. Actualiza las variables de estado y notifica a los oyentes

### Cambio de Nombre del Dispositivo

El controlador soporta dos tipos de dispositivos con diferentes protocolos para cambiar el nombre:

#### Dispositivos con servicio FF12 (característica FF06)

```dart
Future<void> changeName(String name) async {
  if (deviceInfoCharacteristic != null) {
    // Convertir el nombre a bytes ASCII
    List<int> hexArray = List<int>.filled(name.length, 0);
    for (int i = 0; i < name.length; i++) {
      hexArray[i] = name.codeUnitAt(i);
    }

    // Crear el comando (envío directo de los bytes del nombre)
    List<int> command = [];
    command.addAll(hexArray);
    
    // Enviar el comando al dispositivo
    await deviceInfoCharacteristic!.write(command, withoutResponse: false);
    
    // Guardar el nombre en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_name', name);
    
    deviceName = name;
    notifyListeners();
  }
}
```

Para dispositivos con servicio FF12, el proceso es simple:
1. Convierte el nombre a una secuencia de bytes ASCII
2. Envía estos bytes directamente al dispositivo a través de la característica FF06
3. Guarda el nombre en las preferencias compartidas para futuras sesiones

#### Dispositivos con servicio FE60 (característica FE63)

```dart
Future<void> changeName(String name) async {
  if (deviceInfoCharacteristic != null) {
    // Validar longitud del nombre
    List<int> nameBytes = name.codeUnits;
    if (nameBytes.isEmpty || nameBytes.length > 20) {
      throw Exception('El nombre debe tener entre 1 y 20 bytes.');
    }

    // Construir el comando:
    // 0x01: Símbolo de inicio
    // 0xFC: ID fijo
    // 0x07: Comando para cambiar el nombre
    // [len]: Longitud del nombre
    // [Name]: Bytes del nombre
    List<int> command = [0x01, 0xFC, 0x07, nameBytes.length];
    command.addAll(nameBytes);
    
    // Enviar el comando al dispositivo
    await deviceInfoCharacteristic!.write(command, withoutResponse: false);
    
    // Guardar el nombre en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_name', name);
    
    deviceName = name;
    notifyListeners();
  }
}
```

Para dispositivos con servicio FE60, el proceso es más estructurado:
1. Convierte el nombre a bytes y valida que la longitud esté entre 1 y 20 bytes
2. Construye un comando con formato específico:
   - Cabecera: 0x01, 0xFC
   - Comando: 0x07 (cambiar nombre)
   - Longitud del nombre
   - Bytes del nombre
3. Envía el comando a través de la característica FE63
4. Guarda el nombre en las preferencias compartidas

#### Implementación Unificada

El controlador detecta automáticamente el tipo de dispositivo conectado y utiliza el protocolo adecuado:

```dart
Future<void> changeName(String name) async {
  if (deviceInfoCharacteristic == null) return;

  // Determinar qué característica estamos usando
  String charUuid = deviceInfoCharacteristic!.characteristicUuid.str;

  // Crear el comando según el tipo de característica
  List<int> command;
  
  switch (charUuid) {
    case 'ff06':
      command = _createCommandForFF03(name);
      break;
    case 'fe63':
      command = _createCommandForFE63(name);
      break;
    default:
      throw Exception('Característica no soportada: $charUuid');
  }

  // Enviar el comando
  await deviceInfoCharacteristic!.write(command, withoutResponse: false);

  // Guardar nombre en SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('device_name', name);

  deviceName = name;
  notifyListeners();
}
```

Esta implementación unificada:
1. Identifica automáticamente el tipo de dispositivo conectado
2. Genera el comando adecuado según el protocolo del dispositivo
3. Envía el comando y actualiza el nombre en la aplicación
4. Guarda el nombre para futuras sesiones

**Nota importante**: Después de cambiar el nombre en dispositivos FE60, puede ser necesario reiniciar las notificaciones o reconectar el dispositivo para que todos los servicios funcionen correctamente.

## Conversiones de Unidades

El controlador incluye varios métodos para convertir entre diferentes unidades de medida:

- `inchesToMm`: Convierte pulgadas a milímetros
- `mmToInches`: Convierte milímetros a pulgadas
- `hexToMm`: Convierte valores hexadecimales a milímetros
- `mmToCm`: Convierte milímetros a centímetros

Estas conversiones son esenciales para la comunicación precisa con el dispositivo y para mostrar la información correcta al usuario.

## Conclusión

Este controlador proporciona una interfaz completa para interactuar con un escritorio ajustable mediante Bluetooth BLE. Permite controlar el movimiento, monitorear la altura actual y personalizar la configuración del dispositivo, todo ello a través de una API intuitiva y robusta.

## Validación de Dispositivos y Características

### Validación de Dispositivos Compatibles

Durante el escaneo de dispositivos Bluetooth, la aplicación utiliza el método `_hasValidServices` para identificar dispositivos compatibles:

```dart
bool _hasValidServices(ScanResult result) {
  var services = result.advertisementData.serviceUuids;

  if (services.isEmpty) return false;

  for (var service in services) {
    // Normalizar el UUID completo
    String fullUuid = service.str;
    // Extraer solo los 4 caracteres significativos del UUID
    final normalized = DeskServiceConfig.standardizeUuid(fullUuid.toLowerCase());

    if (normalized.endsWith('00805f9b34fb')) {
      // Verificar si es uno de nuestros servicios conocidos de escritorio
      if (DeskServiceConfig.configurations
          .any((config) => config.serviceUuid == fullUuid)) {
        print('\n📱 Device: ${result.device.advName}');
        print('✅ Found desk service: $fullUuid');
        print('Available services:');
        for (var uuid in result.advertisementData.serviceUuids) {
          print('  - ${uuid.toString()}');
        }
        return true;
      }
    }
  }

  return false;
}
```

Este método:
1. Examina los servicios anunciados por el dispositivo durante el escaneo
2. Normaliza los UUIDs para manejar diferentes formatos (16-bit, 32-bit, 128-bit)
3. Verifica si alguno de los servicios anunciados coincide con las configuraciones conocidas de escritorios
4. Registra información detallada sobre los dispositivos compatibles encontrados

La validación se realiza durante el escaneo inicial, filtrando los resultados para mostrar solo dispositivos compatibles:

```dart
_scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
  _scanResults = results
      .where((r) => _hasValidServices(r) && r.device.advName.isNotEmpty)
      .toList();

  if (mounted) {
    setState(() {});
  }
});
```

### Configuración de Notificaciones en Características

La aplicación configura notificaciones en características específicas para recibir actualizaciones en tiempo real del dispositivo:

#### Configuración de Notificaciones para Altura

```dart
Future<void> _discoverServices(BuildContext context) async {
  // ... código existente ...
  
  // Asignar característica de reporte de estado (altura)
  if (config?.reportStateUuids.contains(charUuid) ?? false) {
    reportCharacteristic = characteristic;
    if (characteristic.properties.notify) {
      print('  ℹ️ Setting up notifications...');
      // Configurar notificaciones para la altura
      await reportCharacteristic!.setNotifyValue(true);
      await _listenForNotifications(context);
    }
    // ... código existente ...
  }
  
  // Asignar característica de información del dispositivo
  if (config?.deviceInfoUuids.contains(charUuid) ?? false) {
    deviceInfoCharacteristic = characteristic;
    // Configurar notificaciones solo para dispositivos FE60
    if (charUuid == 'fe63') {
      await characteristic.setNotifyValue(true);
    }
  }
  
  // ... código existente ...
}
```

Este proceso:
1. Verifica si la característica tiene la propiedad `notify` antes de intentar configurar notificaciones
2. Activa las notificaciones con `setNotifyValue(true)`
3. Configura un listener para procesar los datos recibidos
4. Para dispositivos con servicio FE60, también configura notificaciones en la característica de información del dispositivo

#### Escucha de Notificaciones

```dart
Future<void> _listenForNotifications(BuildContext context) async {
  if (reportCharacteristic != null) {
    print('🔔 Iniciando escucha de notificaciones');
    print('🔔 Report characteristic: ${reportCharacteristic!.uuid.str}');

    // Asegurar que las notificaciones estén activadas
    await reportCharacteristic!.setNotifyValue(true);

    reportCharacteristic!.onValueReceived.listen((event) async {
      // Procesar datos recibidos
      // ... código existente ...
    });
  }
}
```

La escucha de notificaciones:
1. Registra información de depuración sobre la característica configurada
2. Asegura que las notificaciones estén activadas
3. Configura un listener que procesa los datos recibidos en tiempo real

### Manejo de Pérdida de Datos

Para detectar y manejar la pérdida de datos de altura, se implementa un temporizador:

```dart
void _resetNoDataTimer(BuildContext context) {
  _noDataTimer?.cancel();

  _noDataTimer = Timer(const Duration(seconds: 5), () async {
    print("No se ha recibido información de altura en los últimos 5 segundos.");

    // Enviar última altura conocida a la API
    if (heightIN != 0.0) {
      await createMovementReport(context);
    }
  });
}
```

Este mecanismo:
1. Se reinicia cada vez que se reciben nuevos datos de altura
2. Si no se reciben datos durante 5 segundos, registra un mensaje de advertencia
3. Envía la última altura conocida a la API para mantener la sincronización

## Configuraciones de Servicio

La aplicación utiliza una estructura de configuración para manejar diferentes tipos de dispositivos:

```dart
class DeskServiceConfig {
  final String serviceUuid;
  final List<String> normalStateUuids;
  final List<String> reportStateUuids;
  final List<String> deviceInfoUuids;

  const DeskServiceConfig({
    required this.serviceUuid,
    required this.normalStateUuids,
    required this.reportStateUuids,
    required this.deviceInfoUuids,
  });

  static const List<DeskServiceConfig> configurations = [
    DeskServiceConfig(
      serviceUuid: 'ff12',
      normalStateUuids: ['ff01'],
      reportStateUuids: ['ff02'],
      deviceInfoUuids: ['ff06'],
    ),
    DeskServiceConfig(
      serviceUuid: 'fe60',
      normalStateUuids: ['fe61'],
      reportStateUuids: ['fe62'],
      deviceInfoUuids: ['fe63'],
    ),
  ];
  
  // ... métodos adicionales ...
}
```

Esta estructura:
1. Define las configuraciones para diferentes tipos de dispositivos (FF12 y FE60)
2. Especifica los UUIDs para diferentes tipos de características:
   - `normalStateUuids`: Características para enviar comandos de control
   - `reportStateUuids`: Características para recibir notificaciones de altura
   - `deviceInfoUuids`: Características para configurar información del dispositivo
3. Facilita la adición de soporte para nuevos tipos de dispositivos en el futuro

## **📜 Licencia**
Este proyecto es de código cerrado y no está disponible para distribución pública.

---

## **📞 Soporte**
Si tienes problemas, contacta con el equipo de desarrollo.

