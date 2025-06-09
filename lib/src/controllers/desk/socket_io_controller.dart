import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import './desk_controller.dart';
import '../../config/app_config.dart';
import '../../api/token_manager.dart';

class DeskSocketService extends ChangeNotifier {
  final DeskController desk;
  final String baseUrl = AppConfig.apiBaseUrl;

  io.Socket? _socket;
  bool _connected = false; // ← flag interno

  bool get isConnected => _connected;

  DeskSocketService(this.desk);

  void connect({required String sUUID, required String sName}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TokenManager.TOKEN_KEY);
    
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery(token != null ? {'token': token} : {})
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _connected = true;
        _socket!.emit('joinDesk', sUUID);
        debugPrint('🔌 Unido a $sUUID');
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
        // ⬇️ Cambio clave: convertimos a num y luego a int
        final target = (data['targetMm'] as num).toInt();
        final cmdId  = (data['cmdId']   as num).toInt();

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
