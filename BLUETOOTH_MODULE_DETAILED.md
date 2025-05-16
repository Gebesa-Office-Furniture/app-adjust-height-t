# Comprehensive Bluetooth Module Technical Documentation

## 1. Hardware Communication Layers

The Bluetooth module architecture consists of four distinct layers that work together to establish and maintain desk device connectivity:

### 1.1 Physical Layer
- **Bluetooth Low Energy (BLE) Version**: 4.2 and above
- **Radio Frequency**: 2.4 GHz ISM band
- **Channel Hopping**: Adaptive frequency hopping across 40 channels
- **Transmission Power**: Class 2 (≤ 2.5 mW, ~10m range)
- **Data Rate**: Up to 1 Mbps

### 1.2 Protocol Layer
- **GATT Profile**: Client role (mobile app) to Server role (desk device)
- **ATT (Attribute Protocol)**: Used for service discovery and characteristic operations
- **Service Discovery**: Active polling for supported service UUIDs (FF12 or FE60)
- **Connection Parameters**:
  - Connection interval: 7.5-100ms (adjustable)
  - Slave latency: 0
  - Supervision timeout: 10 seconds

### 1.3 Service Layer
There are two supported desk device configurations:

#### 1.3.1 Configuration Type A
- **Service UUID**: `0000FF12-0000-1000-8000-00805F9B34FB` (shorthand: FF12)
- **Characteristics**:
  - Control: `0000FF01-0000-1000-8000-00805F9B34FB` (Write, WriteWithoutResponse)
  - Height Reports: `0000FF02-0000-1000-8000-00805F9B34FB` (Notify)
  - Device Info: `0000FF06-0000-1000-8000-00805F9B34FB` (Read, Write)

#### 1.3.2 Configuration Type B
- **Service UUID**: `0000FE60-0000-1000-8000-00805F9B34FB` (shorthand: FE60)
- **Characteristics**:
  - Control: `0000FE61-0000-1000-8000-00805F9B34FB` (Write, WriteWithoutResponse)
  - Height Reports: `0000FE62-0000-1000-8000-00805F9B34FB` (Notify)
  - Device Info: `0000FE63-0000-1000-8000-00805F9B34FB` (Read, Write)

### 1.4 Application Layer
- **Device Discovery Interface**: Scan results filtering and device selection
- **Control Interface**: Up/down movement, memory positions, and absolute height control
- **Status Interface**: Real-time height reporting and height range discovery
- **Configuration Interface**: Memory position setting, device naming

## 2. Permission Management

### 2.1 Required Permissions
- **Android Manifest Permissions**:
  ```xml
  <uses-permission android:name="android.permission.BLUETOOTH" />
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
  <uses-permission android:name="android.permission.BLUETOOTH_SCAN" /> 
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  ```

- **iOS Info.plist Entries**:
  ```xml
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>This app uses Bluetooth to connect and control your adjustable desk</string>
  <key>NSBluetoothPeripheralUsageDescription</key>
  <string>This app uses Bluetooth to connect and control your adjustable desk</string>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app requires location access for Bluetooth scanning</string>
  ```

### 2.2 Permission Request Flow
The `BluetoothPermissionController` class handles the permission flow:

1. **Initial Check**:
   ```dart
   Future<bool> _checkPermission() async {
     return await Permission.bluetoothScan.isGranted && 
            await Permission.bluetoothConnect.isGranted;
   }
   ```

2. **Request Permissions**:
   ```dart
   Future<void> _requestPermission() async {
     final status = await [
       Permission.bluetoothScan,
       Permission.bluetoothConnect,
       Platform.isAndroid ? Permission.location : Permission.locationWhenInUse,
     ].request();
   }
   ```

3. **Handle Permanent Denial**:
   ```dart
   if (await Permission.bluetoothScan.isPermanentlyDenied ||
       await Permission.bluetoothConnect.isPermanentlyDenied) {
     await openAppSettings();
   }
   ```

## 3. Device Discovery Process

### 3.1 Scanning Initialization
```dart
Future<void> startScan() async {
  _isScanning.value = true;
  
  // Set scan mode to low latency
  await FlutterBluePlus.adapterState.where((state) => 
    state == BluetoothAdapterState.on).first;
  
  try {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidScanMode: AndroidScanMode.lowLatency
    );
  } catch (e) {
    _isScanning.value = false;
    _showErrorDialog('Failed to start Bluetooth scan: $e');
  }
}
```

### 3.2 Device Filtering Logic
```dart
bool _hasValidServices(ScanResult result) {
  if (result.advertisementData.serviceUuids.isEmpty) return false;
  
  // Check for desk service UUIDs (FF12 or FE60)
  return result.advertisementData.serviceUuids.any((uuid) {
    final uuidStr = uuid.toLowerCase();
    return uuidStr.contains('ff12') || uuidStr.contains('fe60');
  });
}
```

### 3.3 Scanning Results Processing
```dart
// Listen to scan results with a debounce to avoid UI flicker
FlutterBluePlus.scanResults.listen((results) {
  final validResults = results.where(_hasValidServices).toList();
  
  // Sort by signal strength (RSSI)
  validResults.sort((a, b) => b.rssi.compareTo(a.rssi));
  
  _scanResults.value = validResults;
});
```

### 3.4 Device Selection and Connection
```dart
Future<void> connectToDevice(BluetoothDevice device) async {
  try {
    _connectionState.value = DeviceConnectionState.connecting;
    await device.connect(
      autoConnect: false,
      timeout: const Duration(seconds: 15),
    );
    
    _device = device;
    _saveLastConnectedDevice(device.id.toString(), device.name);
    _connectionState.value = DeviceConnectionState.connected;
    
    // Now discover services
    await _discoverServices();
  } catch (e) {
    _connectionState.value = DeviceConnectionState.disconnected;
    _showConnectionErrorDialog('Failed to connect: $e');
  }
}
```

## 4. Service and Characteristic Discovery

### 4.1 Service Discovery Process
```dart
Future<void> _discoverServices() async {
  if (_device == null) return;
  
  try {
    _services = await _device!.discoverServices();
    
    for (BluetoothService service in _services) {
      final config = _getConfigForService(service.uuid.toString());
      if (config != null) {
        // Found matching service, now map characteristics
        await _mapCharacteristics(service, config);
        _deviceReady = true;
        await _setupNotifications();
        return;
      }
    }
    
    // No supported service found
    throw Exception('No supported service found on this device');
  } catch (e) {
    _showErrorDialog('Service discovery failed: $e');
  }
}
```

### 4.2 Characteristic Mapping
```dart
Future<void> _mapCharacteristics(BluetoothService service, DeskConfig config) async {
  for (BluetoothCharacteristic c in service.characteristics) {
    final uuid = c.uuid.toString().toUpperCase();
    
    if (uuid.contains(config.controlCharUuid)) {
      _controlCharacteristic = c;
    } else if (uuid.contains(config.reportCharUuid)) {
      _reportCharacteristic = c;
    } else if (uuid.contains(config.infoCharUuid)) {
      _infoCharacteristic = c;
    }
  }
  
  // Verify all required characteristics are found
  if (_controlCharacteristic == null || 
      _reportCharacteristic == null || 
      _infoCharacteristic == null) {
    throw Exception('Required characteristics not found');
  }
}
```

### 4.3 Notification Setup
```dart
Future<void> _setupNotifications() async {
  if (_reportCharacteristic == null) return;
  
  try {
    // Enable notifications
    await _reportCharacteristic!.setNotifyValue(true);
    
    // Listen for height updates
    _subscription = _reportCharacteristic!.onValueChanged.listen((value) {
      _processNotification(value);
    });
    
    // Request current height
    await _sendInitialCommand();
    
    // Request height range information
    await _requestHeightRange();
  } catch (e) {
    _showErrorDialog('Failed to setup notifications: $e');
  }
}
```

## 5. Command Protocol Implementation

### 5.1 Base Command Structure
All commands follow a common structure:
```
[Header (2 bytes), Command ID (1 byte), Data Length (1 byte), Data (variable), Checksum (1 byte), Terminator (1 byte)]
```

### 5.2 Basic Movement Commands

#### 5.2.1 Move Up Command
```dart
Future<void> moveUp() async {
  final command = [0xF1, 0xF1, 0x01, 0x00, 0x01, 0x7E];
  
  try {
    await _controlCharacteristic?.write(command, withoutResponse: true);
    _isMoving = true;
    _directionUp = true;
    _startNoDataTimer();
  } catch (e) {
    _showErrorDialog('Failed to send move up command: $e');
  }
}
```

#### 5.2.2 Move Down Command
```dart
Future<void> moveDown() async {
  final command = [0xF1, 0xF1, 0x02, 0x00, 0x02, 0x7E];
  
  try {
    await _controlCharacteristic?.write(command, withoutResponse: true);
    _isMoving = true;
    _directionUp = false;
    _startNoDataTimer();
  } catch (e) {
    _showErrorDialog('Failed to send move down command: $e');
  }
}
```

#### 5.2.3 Stop Command
```dart
Future<void> stop() async {
  final command = [0xF1, 0xF1, 0x0A, 0x00, 0x0A, 0x7E];
  
  try {
    await _controlCharacteristic?.write(command, withoutResponse: true);
    _isMoving = false;
    _cancelNoDataTimer();
    _startStableTimer();
  } catch (e) {
    _showErrorDialog('Failed to send stop command: $e');
  }
}
```

### 5.3 Absolute Height Commands

#### 5.3.1 Move to Specific Height
```dart
Future<void> moveToHeight(double targetHeight) async {
  if (targetHeight < minHeightMM || targetHeight > maxHeightMM) {
    _showErrorDialog('Target height out of range');
    return;
  }
  
  try {
    int heightMM = targetHeight.round();
    
    // Convert to 2-byte representation
    int highByte = (heightMM >> 8) & 0xFF;
    int lowByte = heightMM & 0xFF;
    
    // Calculate checksum
    int checksum = 0x1B + 0x02 + highByte + lowByte;
    
    final command = [0xF1, 0xF1, 0x1B, 0x02, highByte, lowByte, checksum, 0x7E];
    await _controlCharacteristic?.write(command, withoutResponse: true);
    
    _isMoving = true;
    _startNoDataTimer();
  } catch (e) {
    _showErrorDialog('Failed to send move to height command: $e');
  }
}
```

### 5.4 Memory Position Commands

#### 5.4.1 Set Memory Position
```dart
Future<void> setMemoryPosition(int position) async {
  if (position < 1 || position > 4) {
    throw ArgumentError('Invalid memory position: $position');
  }
  
  int commandId;
  switch (position) {
    case 1: commandId = 0x03; break;
    case 2: commandId = 0x04; break;
    case 3: commandId = 0x25; break;
    case 4: commandId = 0x26; break;
  }
  
  final command = [0xF1, 0xF1, commandId, 0x00, commandId, 0x7E];
  
  try {
    await _controlCharacteristic?.write(command, withoutResponse: true);
    
    // Save memory position to local storage and backend
    await _saveMemoryPosition(position, _currentHeightMM);
  } catch (e) {
    _showErrorDialog('Failed to set memory position: $e');
  }
}
```

#### 5.4.2 Move to Memory Position
```dart
Future<void> moveToMemoryPosition(int position) async {
  if (position < 1 || position > 4) {
    throw ArgumentError('Invalid memory position: $position');
  }
  
  int commandId;
  switch (position) {
    case 1: commandId = 0x05; break;
    case 2: commandId = 0x06; break;
    case 3: commandId = 0x27; break;
    case 4: commandId = 0x28; break;
  }
  
  final command = [0xF1, 0xF1, commandId, 0x00, commandId, 0x7E];
  
  try {
    await _controlCharacteristic?.write(command, withoutResponse: true);
    _isMoving = true;
    _startNoDataTimer();
  } catch (e) {
    _showErrorDialog('Failed to move to memory position: $e');
  }
}
```

### 5.5 Device Configuration Commands

#### 5.5.1 Request Height Range
```dart
Future<void> _requestHeightRange() async {
  final command = [0xF1, 0xF1, 0x0C, 0x00, 0x0C, 0x7E];
  
  try {
    await _controlCharacteristic?.write(command, withoutResponse: true);
  } catch (e) {
    _logger.e('Failed to request height range: $e');
  }
}
```

#### 5.5.2 Change Device Name (Type A - FF06)
```dart
Future<void> _changeDeviceNameFF06(String newName) async {
  if (_infoCharacteristic == null) return;
  
  try {
    List<int> nameBytes = utf8.encode(newName);
    int nameLength = nameBytes.length;
    
    List<int> command = [0x01, 0xFC, 0x07, nameLength];
    command.addAll(nameBytes);
    
    await _infoCharacteristic!.write(command, withoutResponse: true);
    await _saveDeviceName(newName);
  } catch (e) {
    _showErrorDialog('Failed to change device name: $e');
  }
}
```

#### 5.5.3 Change Device Name (Type B - FE63)
```dart
Future<void> _changeDeviceNameFE63(String newName) async {
  if (_infoCharacteristic == null) return;
  
  try {
    List<int> nameBytes = utf8.encode(newName);
    int nameLength = nameBytes.length;
    
    List<int> command = [0xF1, 0xF1, 0x0B, nameLength + 2, 0x00, nameLength];
    command.addAll(nameBytes);
    
    // Add checksum
    int checksum = 0;
    for (int i = 2; i < command.length; i++) {
      checksum += command[i];
    }
    command.add(checksum);
    command.add(0x7E);  // Terminator
    
    await _infoCharacteristic!.write(command, withoutResponse: true);
    await _saveDeviceName(newName);
  } catch (e) {
    _showErrorDialog('Failed to change device name: $e');
  }
}
```

#### 5.5.4 Reset Device
```dart
Future<void> resetDevice() async {
  final command = [0x01, 0xFC, 0x19, 0x01, 0x00];
  
  try {
    await _controlCharacteristic?.write(command, withoutResponse: true);
    
    // Wait for device to reset, then reconnect
    await Future.delayed(const Duration(seconds: 5));
    await reconnect();
  } catch (e) {
    _showErrorDialog('Failed to reset device: $e');
  }
}
```

## 6. Notification Handling

### 6.1 Notification Processing
```dart
void _processNotification(List<int> value) {
  if (value.length < 6) return;
  
  // Reset no data timer since we got data
  _resetNoDataTimer();
  
  // Check if this is a height range notification
  if (value.length >= 8 && 
      value[0] == 0xF2 && 
      value[1] == 0xF2 && 
      value[2] == 0x07) {
    
    // Process height range information
    _processHeightRangeNotification(value);
    return;
  }
  
  // Process height update notification
  if (value.length >= 6 && value[2] == 0x0A) {
    // Extract height in mm from bytes 4-5
    final heightMM = (value[4] << 8) | value[5];
    _updateHeight(heightMM);
  }
}
```

### 6.2 Height Range Notification Processing
```dart
void _processHeightRangeNotification(List<int> value) {
  try {
    // Minimum height is in bytes 4-5
    _minHeightMM = (value[4] << 8) | value[5];
    
    // Maximum height is in bytes 6-7
    _maxHeightMM = (value[6] << 8) | value[7];
    
    // Save to local storage
    _prefs.setInt('min_height_mm', _minHeightMM);
    _prefs.setInt('max_height_mm', _maxHeightMM);
    
    _logger.i('Height range: $_minHeightMM - $_maxHeightMM mm');
    
    // Update UI with new height range
    _calculateProgress();
  } catch (e) {
    _logger.e('Error processing height range: $e');
  }
}
```

### 6.3 Height Update and Conversion
```dart
void _updateHeight(int heightMM) {
  if (heightMM < 0) return;
  
  _currentHeightMM = heightMM;
  
  // Convert to user's preferred unit
  if (_measurementController.isMetric) {
    _heightCM = _mmToCm(_currentHeightMM);
    _heightIN = _mmToInches(_currentHeightMM);
    _displayHeight = _heightCM;
    _unit = 'cm';
  } else {
    _heightIN = _mmToInches(_currentHeightMM);
    _heightCM = _mmToCm(_currentHeightMM);
    _displayHeight = _heightIN;
    _unit = 'in';
  }
  
  // Calculate progress percentage for UI
  _calculateProgress();
  
  // Detect if desk is stable (not changing height)
  _detectStability();
  
  // Notify listeners
  notifyListeners();
}
```

### 6.4 Height Stability Detection
```dart
void _detectStability() {
  // Store last few height readings
  _heightReadings.add(_currentHeightMM);
  if (_heightReadings.length > 5) {
    _heightReadings.removeAt(0);
  }
  
  // Check if height has stabilized (not changing)
  if (_heightReadings.length >= 3) {
    bool isStable = true;
    for (int i = 1; i < _heightReadings.length; i++) {
      if (_heightReadings[i] != _heightReadings[0]) {
        isStable = false;
        break;
      }
    }
    
    if (isStable && _isMoving) {
      _isMoving = false;
      _startStableTimer();
    }
  }
}
```

### 6.5 Movement Timers
```dart
void _startNoDataTimer() {
  _cancelNoDataTimer();
  _noDataTimer = Timer(const Duration(seconds: 5), () {
    if (_isMoving) {
      _isMoving = false;
      _startStableTimer();
    }
  });
}

void _startStableTimer() {
  _cancelStableTimer();
  _stableTimer = Timer(const Duration(seconds: 2), () {
    // Desk height has been stable for 2 seconds
    // Report movement completion to backend
    _reportDeskMovement();
  });
}
```

## 7. Unit Conversion and Calculations

### 7.1 Unit Conversion Functions
```dart
// Convert millimeters to inches (with precision)
double _mmToInches(int mm) => mm / 25.4;

// Convert inches to millimeters (with rounding)
int _inchesToMm(double inches) => (inches * 25.4).round();

// Convert millimeters to centimeters
double _mmToCm(int mm) => mm / 10.0;

// Convert centimeters to millimeters
int _cmToMm(double cm) => (cm * 10).round();

// Convert hex representation to millimeters
int _hexToMm(List<int> bytes, int offset) {
  if (bytes.length < offset + 2) return 0;
  return (bytes[offset] << 8) | bytes[offset + 1];
}
```

### 7.2 Progress Calculation
```dart
void _calculateProgress() {
  if (_minHeightMM <= 0 || _maxHeightMM <= 0 || _currentHeightMM <= 0) {
    _progress = 0.0;
    return;
  }
  
  // Calculate percentage of current height within min-max range
  _progress = (_currentHeightMM - _minHeightMM) / 
              (_maxHeightMM - _minHeightMM);
  
  // Ensure progress is between 0 and 1
  _progress = math.max(0.0, math.min(1.0, _progress));
}
```

## 8. Data Persistence Implementation

### 8.1 Device Information Storage
```dart
Future<void> _saveLastConnectedDevice(String deviceId, String deviceName) async {
  await _prefs.setString('last_device_id', deviceId);
  await _prefs.setString('last_device_name', deviceName);
}

Future<BluetoothDevice?> _getLastConnectedDevice() async {
  final deviceId = _prefs.getString('last_device_id');
  if (deviceId == null) return null;
  
  try {
    final id = DeviceIdentifier(deviceId);
    return BluetoothDevice(
      id: id,
      name: _prefs.getString('last_device_name') ?? 'Unknown',
      type: BluetoothDeviceType.le,
    );
  } catch (e) {
    _logger.e('Error getting last device: $e');
    return null;
  }
}
```

### 8.2 Memory Position Storage
```dart
Future<void> _saveMemoryPosition(int position, int heightMM) async {
  final key = 'memory_position_$position';
  await _prefs.setInt(key, heightMM);
  
  // If online, also save to cloud
  if (_connectivityController.isConnected) {
    try {
      await _deskApi.updateMemoryPosition(
        deskId: _deskId, 
        position: position, 
        heightMM: heightMM
      );
    } catch (e) {
      _logger.e('Failed to sync memory position to cloud: $e');
    }
  }
}

Future<int?> _loadMemoryPosition(int position) async {
  final key = 'memory_position_$position';
  return _prefs.getInt(key);
}
```

### 8.3 Height Range Storage
```dart
Future<void> _loadHeightRange() async {
  _minHeightMM = _prefs.getInt('min_height_mm') ?? 650;
  _maxHeightMM = _prefs.getInt('max_height_mm') ?? 1300;
  
  _logger.i('Loaded height range: $_minHeightMM - $_maxHeightMM mm');
}
```

## 9. Error Handling and Recovery Mechanisms

### 9.1 Connection Error Recovery
```dart
Future<bool> reconnect() async {
  if (_connectionState.value == DeviceConnectionState.connected) {
    return true;
  }
  
  try {
    _connectionState.value = DeviceConnectionState.connecting;
    
    // Try to reconnect to last device
    final lastDevice = await _getLastConnectedDevice();
    if (lastDevice == null) {
      throw Exception('No previously connected device found');
    }
    
    await lastDevice.connect(
      autoConnect: false,
      timeout: const Duration(seconds: 15),
    );
    
    _device = lastDevice;
    _connectionState.value = DeviceConnectionState.connected;
    
    // Re-discover services
    await _discoverServices();
    return true;
  } catch (e) {
    _connectionState.value = DeviceConnectionState.disconnected;
    _logger.e('Reconnection failed: $e');
    return false;
  }
}
```

### 9.2 Service Recovery
```dart
Future<void> _recoverServices() async {
  if (_device == null) return;
  
  try {
    // Clear existing references
    _controlCharacteristic = null;
    _reportCharacteristic = null;
    _infoCharacteristic = null;
    
    // Cancel existing notification subscription
    await _subscription?.cancel();
    
    // Rediscover services
    await _discoverServices();
  } catch (e) {
    _logger.e('Service recovery failed: $e');
    // Force full reconnection
    await _device?.disconnect();
    await reconnect();
  }
}
```

### 9.3 Error Dialogs and Handling
```dart
void _showConnectionErrorDialog(String message) {
  showDialog(
    context: _context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Connection Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await reconnect();
          },
          child: Text('Retry'),
        ),
      ],
    ),
  );
}
```

### 9.4 Connection Timeout Handling
```dart
Future<void> _connectWithTimeout(BluetoothDevice device) async {
  bool connected = false;
  
  try {
    // Set a timeout for connection attempts
    await Future.any([
      device.connect(autoConnect: false).then((_) {
        connected = true;
      }),
      Future.delayed(const Duration(seconds: 15)).then((_) {
        if (!connected) {
          throw TimeoutException('Connection timed out');
        }
      })
    ]);
  } catch (e) {
    _logger.e('Connection error: $e');
    
    // Ensure device is properly disconnected before retry
    try {
      await device.disconnect();
    } catch (_) {}
    
    // Propagate error
    rethrow;
  }
}
```

## 10. Advanced Connection State Management

### 10.1 State Machine Implementation
```dart
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  discovering,
  ready,
  reconnecting,
  failed
}

class ConnectionStateMachine {
  ValueNotifier<ConnectionState> state = ValueNotifier(ConnectionState.disconnected);
  
  Future<void> transition(ConnectionState to) async {
    final from = state.value;
    
    // Validate state transitions
    switch (from) {
      case ConnectionState.disconnected:
        if (to != ConnectionState.connecting) {
          throw Exception('Invalid state transition: $from -> $to');
        }
        break;
      
      case ConnectionState.connecting:
        if (to != ConnectionState.connected && 
            to != ConnectionState.failed &&
            to != ConnectionState.disconnected) {
          throw Exception('Invalid state transition: $from -> $to');
        }
        break;
      
      // Additional state validation...
    }
    
    // Perform transition
    _logger.i('BLE State transition: $from -> $to');
    state.value = to;
    
    // Execute entry actions for new state
    switch (to) {
      case ConnectionState.connected:
        await _onConnectedEnter();
        break;
      
      case ConnectionState.disconnected:
        await _onDisconnectedEnter();
        break;
      
      // Additional entry actions...
    }
  }
  
  Future<void> _onConnectedEnter() async {
    // Start service discovery
    await transition(ConnectionState.discovering);
  }
  
  Future<void> _onDisconnectedEnter() async {
    // Clean up resources
    await _subscription?.cancel();
    _subscription = null;
    _controlCharacteristic = null;
    _reportCharacteristic = null;
    _infoCharacteristic = null;
  }
}
```

### 10.2 Lifecycle Management
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      _onResume();
      break;
    case AppLifecycleState.paused:
      _onPause();
      break;
    default:
      break;
  }
}

Future<void> _onResume() async {
  _logger.i('App resumed, checking Bluetooth connection');
  
  // Check Bluetooth adapter state
  final adapterState = await FlutterBluePlus.adapterState.first;
  if (adapterState != BluetoothAdapterState.on) {
    _connectionState.value = DeviceConnectionState.disconnected;
    return;
  }
  
  // Check device connection state
  if (_device != null) {
    try {
      final connected = await _device!.isConnected;
      if (!connected) {
        _logger.i('Device disconnected while app was paused, reconnecting');
        await reconnect();
      } else {
        _logger.i('Device still connected, checking services');
        await _recoverServices();
      }
    } catch (e) {
      _logger.e('Error checking connection: $e');
      await reconnect();
    }
  }
}

void _onPause() {
  _logger.i('App paused');
  _cancelNoDataTimer();
  _cancelStableTimer();
  
  // Optionally disconnect to save power during long pauses
  // await _device?.disconnect();
}
```

## 11. Backend Integration

### 11.1 Device Registration
```dart
Future<void> _registerDeskDevice() async {
  if (_device == null || !_connectivityController.isConnected) return;
  
  try {
    final deviceName = _device!.name;
    final deviceId = _device!.id.toString();
    
    final response = await _deskApi.registerDeskDevice(
      userId: _authController.currentUser!.id,
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: _getDeviceType(),
    );
    
    _deskId = response.data['deskId'];
    _logger.i('Desk registered with ID: $_deskId');
    
    // Save ID locally
    await _prefs.setString('desk_id', _deskId);
  } catch (e) {
    _logger.e('Failed to register desk device: $e');
  }
}
```

### 11.2 Height Change Reporting
```dart
Future<void> _reportDeskMovement() async {
  if (!_connectivityController.isConnected || _deskId == null) return;
  
  try {
    await _deskApi.reportHeightChange(
      deskId: _deskId!,
      heightMM: _currentHeightMM,
      timestamp: DateTime.now().toIso8601String(),
    );
    
    _logger.i('Reported height change: $_currentHeightMM mm');
  } catch (e) {
    _logger.e('Failed to report desk movement: $e');
    
    // Store for later sync
    await _storeOfflineMovement(_currentHeightMM);
  }
}
```

### 11.3 Sync Offline Data
```dart
Future<void> syncOfflineData() async {
  if (!_connectivityController.isConnected) return;
  
  try {
    final offlineMovements = _getStoredOfflineMovements();
    if (offlineMovements.isEmpty) return;
    
    for (final movement in offlineMovements) {
      await _deskApi.reportHeightChange(
        deskId: _deskId!,
        heightMM: movement.height,
        timestamp: movement.timestamp,
      );
    }
    
    // Clear synced data
    await _clearOfflineMovements();
    _logger.i('Synced ${offlineMovements.length} offline movements');
  } catch (e) {
    _logger.e('Failed to sync offline data: $e');
  }
}
```

## 12. Security Considerations

### 12.1 Secure Device Registration
```dart
Future<void> _secureDeviceRegistration() async {
  // Generate device-specific encryption key
  final deviceKey = await _generateDeviceKey();
  
  // Encrypt device ID using user's account key
  final encryptedDeviceId = _encryptData(
    _device!.id.toString(), 
    _authController.userEncryptionKey
  );
  
  // Register with encrypted ID
  await _deskApi.secureRegisterDevice(
    userId: _authController.currentUser!.id,
    encryptedDeviceId: encryptedDeviceId,
    publicKey: deviceKey.publicKey,
  );
}
```

### 12.2 Data Validation
```dart
bool _validateHeightData(List<int> data) {
  if (data.length < 6) return false;
  
  // Verify packet structure
  if (data[0] != 0xF1 && data[0] != 0xF2) return false;
  
  // Verify packet length matches data length field
  if (data.length != data[3] + 6) return false;
  
  // Verify checksum (sum of all bytes except header and terminator)
  int checksum = 0;
  for (int i = 2; i < data.length - 2; i++) {
    checksum += data[i];
  }
  
  return (checksum & 0xFF) == data[data.length - 2];
}
```

## 13. Advanced Usage Features

### 13.1 Desk Height Analytics
```dart
class DeskHeightAnalytics {
  final List<HeightRecord> _heightRecords = [];
  int _standingTimeToday = 0; // seconds
  int _sittingTimeToday = 0; // seconds
  late DateTime _lastStatusChangeTime;
  bool _isStanding = false;
  
  void recordHeight(int heightMM, DateTime timestamp) {
    _heightRecords.add(HeightRecord(height: heightMM, timestamp: timestamp));
    
    // Determine if user is standing or sitting
    final isCurrentlyStanding = _isStandingHeight(heightMM);
    
    // If status changed, update timing
    if (isCurrentlyStanding != _isStanding) {
      _updateTimeTracking();
      _isStanding = isCurrentlyStanding;
      _lastStatusChangeTime = timestamp;
    }
  }
  
  void _updateTimeTracking() {
    final now = DateTime.now();
    final duration = now.difference(_lastStatusChangeTime).inSeconds;
    
    if (_isStanding) {
      _standingTimeToday += duration;
    } else {
      _sittingTimeToday += duration;
    }
  }
  
  bool _isStandingHeight(int heightMM) {
    // Typical standing height is above 1000mm
    return heightMM > 1000;
  }
  
  Map<String, dynamic> getDailyStats() {
    _updateTimeTracking(); // Ensure times are current
    
    return {
      'standingTime': _standingTimeToday,
      'sittingTime': _sittingTimeToday,
      'standingPercentage': _standingTimeToday / 
                          (_standingTimeToday + _sittingTimeToday) * 100,
      'positionChanges': _countPositionChanges(),
      'totalActiveTime': _standingTimeToday + _sittingTimeToday,
    };
  }
  
  int _countPositionChanges() {
    int changes = 0;
    bool lastWasStanding = false;
    bool firstRecord = true;
    
    for (final record in _heightRecords) {
      final isStanding = _isStandingHeight(record.height);
      
      if (firstRecord) {
        lastWasStanding = isStanding;
        firstRecord = false;
        continue;
      }
      
      if (isStanding != lastWasStanding) {
        changes++;
        lastWasStanding = isStanding;
      }
    }
    
    return changes;
  }
}
```

### 13.2 Gesture Control
```dart
class DeskGestureController {
  final DeskController _deskController;
  Timer? _longPressTimer;
  bool _isMoving = false;
  
  DeskGestureController(this._deskController);
  
  void onUpButtonPressed() {
    _deskController.moveUp();
    _isMoving = true;
  }
  
  void onUpButtonLongPressStart() {
    _longPressTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (!_isMoving) {
        _deskController.moveUp();
        _isMoving = true;
      }
    });
  }
  
  void onButtonReleased() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    
    if (_isMoving) {
      _deskController.stop();
      _isMoving = false;
    }
  }
  
  void onDownButtonPressed() {
    _deskController.moveDown();
    _isMoving = true;
  }
  
  void onDownButtonLongPressStart() {
    _longPressTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (!_isMoving) {
        _deskController.moveDown();
        _isMoving = true;
      }
    });
  }
  
  // Additional gesture methods for swipe-to-adjust, etc.
}
```

## 14. Testing and Validation

### 14.1 Connection Validation Test
```dart
Future<ValidationResult> validateConnection() async {
  final result = ValidationResult();
  
  // Test 1: Bluetooth adapter
  try {
    final adapterState = await FlutterBluePlus.adapterState.first;
    result.addTest('Bluetooth adapter', 
      adapterState == BluetoothAdapterState.on);
  } catch (e) {
    result.addTest('Bluetooth adapter', false, error: e.toString());
  }
  
  // Test 2: Permissions
  try {
    final hasPermissions = await _permissionController.checkPermission();
    result.addTest('Bluetooth permissions', hasPermissions);
  } catch (e) {
    result.addTest('Bluetooth permissions', false, error: e.toString());
  }
  
  // Test 3: Device connection
  if (_device != null) {
    try {
      final connected = await _device!.isConnected;
      result.addTest('Device connection', connected);
      
      // Only proceed with more tests if connected
      if (connected) {
        // Test 4: Service discovery
        result.addTest('Service discovery', 
          _controlCharacteristic != null && 
          _reportCharacteristic != null);
        
        // Test 5: Height reporting
        try {
          await _requestHeightRange();
          result.addTest('Height reporting', _minHeightMM > 0 && _maxHeightMM > 0);
        } catch (e) {
          result.addTest('Height reporting', false, error: e.toString());
        }
      }
    } catch (e) {
      result.addTest('Device connection', false, error: e.toString());
    }
  } else {
    result.addTest('Device connection', false, error: 'No device selected');
  }
  
  return result;
}
```

### 14.2 Mock Device Implementation
```dart
class MockBluetoothDesk implements BluetoothDevice {
  @override
  DeviceIdentifier get id => DeviceIdentifier('00:00:00:00:00:00');
  
  @override
  String get name => 'Mock Desk';
  
  @override
  BluetoothDeviceType get type => BluetoothDeviceType.le;
  
  final StreamController<BluetoothConnectionState> _connectionStateController = 
      StreamController.broadcast();
  
  bool _isConnected = false;
  
  @override
  Stream<BluetoothConnectionState> get connectionState => 
      _connectionStateController.stream;
  
  @override
  Future<void> connect({
    Duration? timeout, 
    bool autoConnect = false,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    _isConnected = true;
    _connectionStateController.add(BluetoothConnectionState.connected);
  }
  
  @override
  Future<void> disconnect() async {
    await Future.delayed(Duration(milliseconds: 300));
    _isConnected = false;
    _connectionStateController.add(BluetoothConnectionState.disconnected);
  }
  
  @override
  Future<bool> get isConnected async => _isConnected;
  
  @override
  Future<List<BluetoothService>> discoverServices() async {
    await Future.delayed(Duration(milliseconds: 800));
    
    // Create mock FF12 service
    final mockService = MockBluetoothService(
      uuid: Guid('0000FF12-0000-1000-8000-00805F9B34FB'),
      characteristics: [
        MockBluetoothCharacteristic(
          uuid: Guid('0000FF01-0000-1000-8000-00805F9B34FB'),
          properties: CharacteristicProperties(write: true),
        ),
        MockBluetoothCharacteristic(
          uuid: Guid('0000FF02-0000-1000-8000-00805F9B34FB'),
          properties: CharacteristicProperties(notify: true),
        ),
        MockBluetoothCharacteristic(
          uuid: Guid('0000FF06-0000-1000-8000-00805F9B34FB'),
          properties: CharacteristicProperties(
            read: true, 
            write: true,
          ),
        ),
      ],
    );
    
    return [mockService];
  }
}
```

## 15. Platform-Specific Implementations

### 15.1 Android-Specific Handling
```dart
Future<void> _configureAndroidSpecifics() async {
  if (Platform.isAndroid) {
    try {
      // Request higher priority for Android connections
      await FlutterBluePlus.setLogLevel(LogLevel.debug);
      
      // Some Samsung devices require this connection parameter
      if (await isSamsungDevice()) {
        _connectionParams = {
          'autoConnect': false,
          'androidConnectionParams': {
            'timeout': 15000,
            'minConnectionInterval': 6, // 7.5ms
            'maxConnectionInterval': 24, // 30ms
          }
        };
      }
    } catch (e) {
      _logger.e('Failed to configure Android specifics: $e');
    }
  }
}

Future<bool> isSamsungDevice() async {
  try {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    return deviceInfo.manufacturer.toLowerCase().contains('samsung');
  } catch (e) {
    return false;
  }
}
```

### 15.2 iOS-Specific Handling
```dart
Future<void> _configureIOSSpecifics() async {
  if (Platform.isIOS) {
    try {
      // Request state restoration for iOS background reconnection
      await FlutterBluePlus.turnOn();
      
      // iOS sometimes needs delayed notifications
      if (_reportCharacteristic != null) {
        await Future.delayed(Duration(milliseconds: 300));
        await _reportCharacteristic!.setNotifyValue(true);
      }
    } catch (e) {
      _logger.e('Failed to configure iOS specifics: $e');
    }
  }
}
```

## 16. Performance Optimizations

### 16.1 Batched Commands
```dart
Future<void> _sendBatchedCommands(List<List<int>> commands) async {
  if (_controlCharacteristic == null) return;
  
  try {
    for (final command in commands) {
      await _controlCharacteristic!.write(command, withoutResponse: true);
      // Small delay to avoid overloading the BLE stack
      await Future.delayed(Duration(milliseconds: 50));
    }
  } catch (e) {
    _logger.e('Failed to send batched commands: $e');
  }
}
```

### 16.2 Connection Parameter Optimization
```dart
Future<void> _optimizeConnectionParameters() async {
  if (Platform.isAndroid) {
    try {
      // Request a faster connection interval for better responsiveness
      // during active use, but slower interval when idle to save battery
      if (_isMoving) {
        await FlutterBluePlus.requestConnectionPriority(
          _device!.id, 
          ConnectionPriority.highPerformance
        );
      } else {
        await FlutterBluePlus.requestConnectionPriority(
          _device!.id, 
          ConnectionPriority.balanced
        );
      }
    } catch (e) {
      _logger.e('Failed to optimize connection parameters: $e');
    }
  }
}
```

### 16.3 Notification Throttling
```dart
StreamSubscription<List<int>>? _createThrottledSubscription() {
  // Use throttling to avoid UI updates that are too frequent
  return _reportCharacteristic?.onValueChanged
      .throttleTime(Duration(milliseconds: 100))
      .listen((value) {
    _processNotification(value);
  });
}
```