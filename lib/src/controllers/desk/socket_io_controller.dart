import 'package:socket_io_client/socket_io_client.dart' as io;
import 'desk_controller.dart';
import 'package:controller/src/config/app_config.dart';

class DeskSocketService {
  final DeskController desk; // controla el BLE
  io.Socket? _socket;
  final String baseUrl = AppConfig.apiBaseUrl;

  DeskSocketService(this.desk);

  bool get isConnected => _socket?.connected ?? false; // ✅ NUEVO
  io.Socket? get socket => _socket; // opcional, por comodidad

  /// Conecta y se une a la sala del escritorio
  void connect({
    required int deskId, // id que te da la API / BD
  }) {
    _socket = io.io(
      baseUrl,
      {
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    _socket!.onConnect((_) {
      _socket!.emit('joinDesk', deskId); // 1️⃣
      print('🔌 Conectado y unido a desk $deskId');
    });

    // 2️⃣ Escuchar la orden de altura
    _socket!.on('desk:height', (data) async {
      final int targetMm = data['targetMm'];
      final int cmdId = data['cmdId'];
      print('📥 Orden: $targetMm mm (cmd $cmdId)');

      desk.moveToHeight(targetMm); // 3️⃣ Bluetooth

      // 4️⃣ Confirmar al backend
      _socket!.emit('desk:ack', {'cmdId': cmdId});
      print('📤 ACK enviado cmd $cmdId');
    });

    _socket!.onDisconnect((_) => print('🛑 Socket desconectado'));
    _socket!.connect();
  }

  void dispose() => _socket?.dispose();
}
