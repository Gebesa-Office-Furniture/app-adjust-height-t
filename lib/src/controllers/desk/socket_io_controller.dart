// services/desk_socket_service.dart
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import './desk_controller.dart';
import '../../config/app_config.dart';

class DeskSocketService extends ChangeNotifier {
  final DeskController desk;
  final String baseUrl = AppConfig.apiBaseUrl;

  io.Socket? _socket;
  bool _connected = false; // ← flag interno

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
        notifyListeners(); // 🔔
      })
      ..onDisconnect((_) {
        _connected = false;
        debugPrint('🛑 Socket desconectado');
        notifyListeners(); // 🔔
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
