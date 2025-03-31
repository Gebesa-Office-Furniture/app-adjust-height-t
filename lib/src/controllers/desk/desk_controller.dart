import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:controller/src/api/desk_api.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routines/routine_controller.dart';
import '../settings/measurement_controller.dart';

class DeskController extends ChangeNotifier {
  int? rssi;
  int? mtuSize;
  BluetoothConnectionState? connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> services = [];
  bool isDiscoveringServices = false;
  bool isConnecting = false;
  bool isDisconnecting = false;

  late StreamSubscription<BluetoothConnectionState> connectionStateSubscription;
  late StreamSubscription<int> mtuSubscription;
  BluetoothCharacteristic? targetCharacteristic;
  BluetoothCharacteristic? deviceInfoCharacteristic;
  BluetoothCharacteristic? reportCharacteristic;

  double heightMM = 0;
  double minHeightMM = 0;
  double maxHeightMM = 0;

  String connectionText = "";
  double? heightIN = 0.0;
  List<int> heightHex = [0x00, 0x00];

  bool isPressed = false;
  bool isPressedDown = false;

  Timer? upTimer;
  Timer? downTimer;

  BluetoothDevice? device;

  final String serviceUuid = "ff12";
  final String characteristicNormalStateUuid = "ff01";
  final String characteristicReportStateUuid = "ff02";
  final String characteristicDeviceInfoUuid = "ff06";

  AnimationController? _controller;
  double minHeight = 0;
  double maxHeight = 0;
  double progress = 0;
  int currentIndex = 1;

  String? deviceName = "";
  bool deviceReady = false;

  bool memory1Configured = false;
  bool memory2Configured = false;
  bool memory3Configured = false;

  Timer? _noDataTimer;
  bool firstConnection = true;
  int memorySlot = 0;

  Timer? _stableTimer;
  bool isStable = true;

  DeskController() {
    loadSavedName();
  }

  /// Loads the saved device name from SharedPreferences
  Future<void> loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('device_name');
    if (savedName != null) {
      deviceName = savedName;
      notifyListeners();
    }
  }

  void setDevice(BluetoothDevice? newDevice) {
    device = newDevice;
    if (device != null) {
      deviceName = device!.advName;
    }
    if (newDevice == null) {
      deviceName = "";
      deviceReady = false;
    }
    notifyListeners();
  }

  void listenToConnectionState(TickerProvider vsync, BuildContext context) {
    if (device == null) {
      deviceReady = true;
      notifyListeners();
      return;
    }
    connectionStateSubscription = device!.connectionState.listen((state) async {
      connectionState = state;
      notifyListeners();

      if (state == BluetoothConnectionState.connected) {
        await _discoverServices(context);

        _controller = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: vsync,
        )..addListener(() {
            currentIndex = 1 + ((_controller!.value * 59).floor());
            notifyListeners();
          });
      }

      deviceReady = true;
      notifyListeners();
    });
  }

  Future<void> _discoverServices(BuildContext context) async {
    isDiscoveringServices = true;
    notifyListeners();

    final discoveredServices = await device!.discoverServices();
    for (BluetoothService service in discoveredServices) {
      if (service.uuid.toString() == serviceUuid) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          print(characteristic.uuid.toString());
          if (characteristic.uuid.toString() == characteristicNormalStateUuid) {
            targetCharacteristic = characteristic;
          } else if (characteristic.uuid.toString() ==
              characteristicReportStateUuid) {
            reportCharacteristic = characteristic;
            await _listenForNotifications(context);
            _sendInitialCommand();

            Future.delayed(const Duration(milliseconds: 200), () {
              requestHeightRange();
              //TODO remove to get the height from the desk
              deviceReady = true;
              notifyListeners();
            });
          } else if (characteristic.uuid.toString() ==
              characteristicDeviceInfoUuid) {
            deviceInfoCharacteristic = characteristic;
          }
        }
      }
    }

    isDiscoveringServices = false;
    notifyListeners();
  }

  Future<void> _listenForNotifications(BuildContext context) async {
    if (reportCharacteristic != null) {
      await reportCharacteristic!.setNotifyValue(true);
      reportCharacteristic!.onValueReceived.listen((event) async {
        //reset timer
        _resetNoDataTimer(context);
        _resetStableTimer();

        if (event[0] == 0xF2 && event[1] == 0xF2 && event[2] == 0x07) {
          // Extraer los valores
          int max = (event[4] << 8) | event[5]; // Altura máxima en mm
          int min = (event[6] << 8) | event[7]; // Altura mínima en mm

          minHeightMM = min.toDouble();
          maxHeightMM = max.toDouble();

          heightMM = inchesToMm(heightIN!);

          print('Altura máxima: ${max / 25.4} in');
          print('Altura mínima: ${min / 25.4} in');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setDouble('maxHeightDesk', max / 25.4);
          prefs.setDouble('minHeightDesk', min / 25.4);

          maxHeight = max / 25.4;
          minHeight = min / 25.4;

          progress =
              calculateProgressPercentage(heightIN!, minHeight, maxHeight);

          firstConnection = false;
          notifyListeners();
          return;
        }

        // Obtener los valores de los bytes de altura
        final dataH = event[4];
        final dataL = event[5];

        // Convertir a hexadecimal y luego a decimal
        final hex = dataH.toRadixString(16).padLeft(2, '0') +
            dataL.toRadixString(16).padLeft(2, '0');
        final decimal = int.parse(hex, radix: 16);

        // Asumimos que el valor está en milímetros y lo convertimos a pulgadas
        final distance = decimal /
            10; // Divide por 10 para convertir a pulgadas si está en décimas de pulgada

        // Actualizar `heightIN`
        heightIN = distance;
        heightHex = [dataH, dataL];

        //verifica si height

        //get progress between min and max height

        // Verificar si la altura está dentro del rango esperado
        if (heightIN! < minHeight) {
          return;
        } else if (heightIN! > maxHeight) {
          return;
        }

        heightMM = inchesToMm(heightIN!);

        print("Altura actual: $heightIN pulgadas");
        print("Altura actual: $heightMM mm");

        progress = calculateProgressPercentage(heightIN!, minHeight, maxHeight);

        notifyListeners();
      });
    }
  }

  void _resetNoDataTimer(BuildContext context) {
    _noDataTimer?.cancel();

    _noDataTimer = Timer(const Duration(seconds: 5), () async {
      print(
          "No se ha recibido información de altura en los últimos 5 segundos.");

      //send last height to api
      if (heightIN != 0.0) {
        await createMovementReport(context);
      }
    });
  }

  void _resetStableTimer() {
    _stableTimer?.cancel();
    isStable = false;
    notifyListeners();

    _stableTimer = Timer(const Duration(seconds: 1), () {
      isStable = true;
      notifyListeners();
    });
  }

  Future createMovementReport(BuildContext context) async {
    if (await InternetConnection().hasInternetAccess) {
      var routineController =
          Provider.of<RoutineController>(context, listen: false);
      int idRoutine = -1;
      if (routineController.isActive) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        idRoutine = prefs.getInt('routineId') ?? -1;
      }

      await DeskApi.moveDeskToPosition(0, heightIN!, idRoutine)
          .then((response) {
        if (response['success']) {
          print("Se ha enviado la altura al servidor $heightIN");
        }
      });
    }
    memorySlot = 0;
    notifyListeners();
  }

  double calculateProgressPercentage(
      double heightIN, double minHeight, double maxHeight) {
    if (heightIN < minHeight) return 0.0; // Menor que la altura mínima.
    if (heightIN > maxHeight) return 100.0; // Mayor que la altura máxima.

    return ((heightIN - minHeight) / (maxHeight - minHeight)) * 100;
  }

  void _sendInitialCommand() {
    targetCharacteristic
        ?.write([0xF1, 0xF1, 0x07, 0x00, 0x07, 0x7E], withoutResponse: true);
  }

  void requestHeightRange() {
    // Comando para solicitar el rango de altura
    List<int> command = [0xF1, 0xF1, 0x0C, 0x00, 0x0C, 0x7E];

    targetCharacteristic!.write(command, withoutResponse: true);
  }

  void moveUp() {
    final data = [0xF1, 0xF1, 0x01, 0x00, 0x01, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
  }

  void moveDown() {
    final data = [0xF1, 0xF1, 0x02, 0x00, 0x02, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
  }

  //change name
  List<int> convertNameToHex(String name) {
    // Crear una lista de enteros con la longitud del nombre
    List<int> hexArray = List<int>.filled(name.length, 0);

    // Recorrer cada letra del nombre
    for (int i = 0; i < name.length; i++) {
      hexArray[i] = name.codeUnitAt(i);
    }

    return hexArray;
  }

  //change name
  Future<void> changeName(String name) async {
    if (deviceInfoCharacteristic != null) {
      // Convertir el nombre a bytes ASCII
      List<int> hexArray = convertNameToHex(name);

      print("Nombre convertido a hex: $hexArray");

      // Crear el comando con la longitud adecuada
      List<int> command = [];

      // Copiar el nombre en el comando
      command.addAll(hexArray);

      print("Comando final: $command");

      // Enviar el comando al dispositivo
      await deviceInfoCharacteristic!.write(command, withoutResponse: false);

      // Save name to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_name', name);

      deviceName = name;
      notifyListeners();
    }
  }

  //move to specific height
  void moveToHeight(int mm) async {
    if (targetCharacteristic != null) {
      // Generar el comando con la altura deseada en pulgadas

      String hexStr = mm.toRadixString(16).padLeft(4, '0');

      List<int> bytes = [];
      for (int i = 0; i < hexStr.length; i += 2) {
        bytes.add(int.parse(hexStr.substring(i, i + 2), radix: 16));
      }

      print("Comando generado para mover a $mm mm de altura: $bytes");

      List<int> command = periferial(bytes);

      // // Enviar el comando al targetCharacteristic
      await targetCharacteristic!
          .write(command, withoutResponse: true, allowLongWrite: false);
      // print("Comando enviado para mover a $inches pulgadas de altura");
    } else {
      print("Característica de destino no disponible");
    }
  }

  List<int> periferial(List<int> hexValue) {
    List<int> periferialCommand = List.filled(8, 0);
    int checkSum = 0x00;

    periferialCommand[0] = 0xF1;
    periferialCommand[1] = 0xF1;
    periferialCommand[2] = 0x1B;
    periferialCommand[3] = 0x02;

    int highByte = hexValue[0];
    int lowByte = hexValue[1];

    periferialCommand[4] = highByte;
    periferialCommand[5] = lowByte;

    // Calcular el checksum
    for (int i = 2; i < 6; i++) {
      checkSum += periferialCommand[i];
    }
    periferialCommand[6] =
        checkSum & 0xFF; // Asegurarse de que el checksum esté dentro de 1 byte
    periferialCommand[7] = 0x7E;

    return periferialCommand;
  }

  List<int> inchToHex(double inch) {
    int inches = inch.round();

    // Convertir a milésimas de pulgada
    int milliInches = (inches * 25.5).toInt();

    // Convertir a cadena hexadecimal
    String hexStr = milliInches.toRadixString(16).padLeft(4, '0');

    List<int> bytes = [];
    for (int i = 0; i < hexStr.length; i += 2) {
      bytes.add(int.parse(hexStr.substring(i, i + 2), radix: 16));
    }

    return bytes;
  }

  //NEW
  // int cmToMm(double cm) {
  //   // Convertir centímetros a milímetros (1 cm = 10 mm)
  //   return (cm * 10).round();
  // }

  // int inchToMm(double inch) {
  //   // Convertir pulgadas a milímetros (1 inch = 25.4 mm)
  //   return (inch * 25.5).round();
  // }

  // List<int> mmToHex(int milliMillimeters) {
  //   // Convertir milímetros a hexadecimal
  //   String hexStr = milliMillimeters.toRadixString(16).toUpperCase();

  //   // Asegurar que la longitud sea par (si es impar, agregamos un 0 al principio)
  //   if (hexStr.length % 2 != 0) {
  //     hexStr = '0$hexStr';
  //   }

  //   // Asegurar que siempre sean 2 bytes (agregar ceros al principio si es necesario)
  //   while (hexStr.length < 4) {
  //     hexStr = '00$hexStr';
  //   }

  //   List<int> bytes = [];

  //   // Convertir la cadena hexadecimal a una lista de bytes
  //   for (int i = 0; i < hexStr.length; i += 2) {
  //     bytes.add(int.parse(hexStr.substring(i, i + 2), radix: 16));
  //   }

  //   return bytes;
  // }

  // // Método para combinar los dos bytes y convertir a un valor decimal
  // double hexToInches(int dataH, int dataL) {
  //   // Convertir los dos bytes a un valor decimal
  //   final hex = dataH.toRadixString(16).padLeft(2, '0') +
  //       dataL.toRadixString(16).padLeft(2, '0');
  //   var decimal =
  //       int.parse(hex, radix: 16); // Convertir de hexadecimal a decimal
  //   return decimal / 10; // Convertir a pulgadas
  // }

  // double hexToCm(int dataH, int dataL) {
  //   // Convertir los dos bytes a un valor decimal
  //   final hex = dataH.toRadixString(16).padLeft(2, '0') +
  //       dataL.toRadixString(16).padLeft(2, '0');

  //   // Convertir de hexadecimal a decimal
  //   var decimal = int.parse(hex, radix: 16);

  //   // Convertir de milésimas de pulgada a pulgadas
  //   double inches = decimal / 10.0;

  //   // Convertir de pulgadas a centímetros
  //   return inches * 2.54; // Convertir de pulgadas a centímetros
  // }

//ANOTHERS NEW
  /// Converts millimeters to centimeters with high precision
  /// @param mm1 First byte of height in hexadecimal
  /// @param mm2 Second byte of height in hexadecimal
  /// @return Height in centimeters as double
  double hexToCm(int mm1, int mm2) {
    int heightMm = (mm1 << 8) | mm2;
    return heightMm / 10.0;
  }

  /// Converts millimeters to inches with high precision
  /// @param mm1 First byte of height in hexadecimal
  /// @param mm2 Second byte of height in hexadecimal
  /// @return Height in inches as double
  double hexToInches(int mm1, int mm2) {
    int heightMm = (mm1 << 8) | mm2;
    return heightMm / 25.4;
  }

  /// Converts centimeters to millimeters for desk movement
  /// @param cm Height in centimeters
  /// @return Height in millimeters as integer
  int cmToMm(double cm) {
    return (cm * 10).round();
  }

  /// Converts inches to millimeters for desk movement with high precision
  /// @param inches Height in inches
  /// @return Height in millimeters as double
  double inchesToMm(double inches) {
    return inches * 25.4; // 1 inch = 25.4 mm (exact conversion)
  }

  //hex to mm
  /// Converts hex values to millimeters
  /// @param dataH High byte of height in hexadecimal
  /// @param dataL Low byte of height in hexadecimal
  /// @return Height in millimeters as integer
  int hexToMm(int dataH, int dataL) {
    return (dataH << 8) | dataL;
  }

  //covert mm to inches
  double mmToInches(double mm) {
    return mm / 25.4;
  }

  //covert mm to cm
  double mmToCm(double mm) {
    return mm / 10;
  }

  //let go command
  void letGo() {
    final data = [0xF1, 0xF1, 0x0c, 0x00, 0x0c, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
  }

  //reset memory confired
  void resetMemoryCofigured() {
    memory1Configured = false;
    memory2Configured = false;
    memory3Configured = false;
    notifyListeners();
  }

  //setup memory position 1
  void setupMemory1() async {
    final data = [0xF1, 0xF1, 0x03, 0x00, 0x03, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
    memory1Configured = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('memory1', heightIN!);

    if (await InternetConnection().hasInternetAccess) {
      DeskApi.saveMemoryDesk(1, heightIN!);
    }

    Future.delayed(const Duration(seconds: 2), () {
      memory1Configured = false;
      notifyListeners();
    });
  }

  //setup memory position 2
  void setupMemory2() async {
    final data = [0xF1, 0xF1, 0x04, 0x00, 0x04, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
    memory2Configured = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('memory2', heightIN!);

    if (await InternetConnection().hasInternetAccess) {
      DeskApi.saveMemoryDesk(2, heightIN!);
    }

    Future.delayed(const Duration(seconds: 2), () {
      memory2Configured = false;
      notifyListeners();
    });
  }

  //setup memory position 3
  void setupMemory3() async {
    final data = [0xF1, 0xF1, 0x25, 0x00, 0x25, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
    memory3Configured = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('memory3', heightIN!);

    if (await InternetConnection().hasInternetAccess) {
      DeskApi.saveMemoryDesk(3, heightIN!);
    }

    Future.delayed(const Duration(seconds: 2), () {
      memory3Configured = false;
      notifyListeners();
    });
  }

  //setup memory position 4
  void setupMemory4() {
    final data = [0xF1, 0xF1, 0x26, 0x00, 0x26, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
  }

  //move memory position 1
  void moveMemory1() {
    final data = [0xF1, 0xF1, 0x05, 0x00, 0x05, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
    memorySlot = 1;
    notifyListeners();
  }

  //move memory position 2
  void moveMemory2() {
    final data = [0xF1, 0xF1, 0x06, 0x00, 0x06, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
    memorySlot = 2;
    notifyListeners();
  }

  //move memory position 3
  void moveMemory3() {
    final data = [0xF1, 0xF1, 0x27, 0x00, 0x27, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
    memorySlot = 3;
    notifyListeners();
  }

  //move memory position 4
  void moveMemory4() {
    final data = [0xF1, 0xF1, 0x28, 0x00, 0x28, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
    memorySlot = 4;
    notifyListeners();
  }

  void sendStopCommand() {
    List<int> data = [0xF1, 0xF1, 0x0A, 0x00, 0x0A, 0x7E];
    targetCharacteristic!.write(data, withoutResponse: true);
  }

  void sendEmergencyStopCommand(BluetoothCharacteristic characteristic) {
    List<int> data = [0xF1, 0xF1, 0x2B, 0x00, 0x2B, 0x7E];
    characteristic.write(data, withoutResponse: true);
  }

  //manage time for long press, send commands each 200ms
  void startUpTimer() {
    upTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      moveUp();
    });
  }

  void startDownTimer() {
    downTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      moveDown();
    });
  }

  void disconnect() {
    if (device == null) {
      return;
    }
    device!.disconnect();
    device = null;
    _controller!.reset();
    _controller!.dispose();
    notifyListeners();
  }
}
