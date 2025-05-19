// lib/pages/desk_debug_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/desk/desk_controller.dart';
import '../../controllers/desk/socket_io_controller.dart';

class DeskDebugPage extends StatefulWidget {
  const DeskDebugPage({super.key});

  @override
  State<DeskDebugPage> createState() => _DeskDebugPageState();
}

class _DeskDebugPageState extends State<DeskDebugPage> {
  final _deskIdCtrl = TextEditingController(text: '1');
  final _targetCtrl = TextEditingController(text: '900');

  @override
  void dispose() {
    _deskIdCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deskCtrl = context.watch<DeskController>();
    final socketSvc = context.watch<DeskSocketService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Desk Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ───── Conexión al backend ─────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _deskIdCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Desk ID', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final id = int.tryParse(_deskIdCtrl.text);
                    if (id != null) {
                      socketSvc.connect(deskId: id);
                    }
                  },
                  child: const Text('Conectar WS'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ───── Estado actual ─────
            Card(
              child: ListTile(
                title: const Text('Estado WebSocket'),
                subtitle:
                    Text(socketSvc.isConnected ? 'Conectado' : 'Desconectado'),
                trailing: socketSvc.isConnected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Altura actual'),
                subtitle: Text('${deskCtrl.heightMM.toStringAsFixed(0)} mm'),
              ),
            ),
            // ───── Mover escritorio manual (BLE local) ─────
            const SizedBox(height: 12),
            TextField(
              controller: _targetCtrl,
              decoration: const InputDecoration(
                labelText: 'Objetivo (mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final mm = int.tryParse(_targetCtrl.text);
                if (mm != null) deskCtrl.moveToHeight(mm);
              },
              child: const Text('Mover via BLE'),
            ),
            // ───── Log rápido ─────
            const SizedBox(height: 20),
            const Text('Últimos comandos recibidos',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const _LogViewer(),
          ],
        ),
      ),
    );
  }
}

/// Widget muy simple que muestra los logs que imprime SocketService
/// (debiste invocar debugPrint en DeskSocketService para verlo).
class _LogViewer extends StatelessWidget {
  const _LogViewer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Scrollbar(
        child: StreamBuilder<String>(
          // Usamos DebugPrintListener para capturar prints globales
          stream: _debugPrintStream,
          builder: (_, snap) => Text(
            (snap.data ?? ''),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}

/// Convierte debugPrint en un stream para mostrarlo en pantalla.
/// Coloca esto en un archivo util si quieres reutilizarlo.
final _debugPrintStream = (() {
  final ctrl = StreamController<String>.broadcast();
  debugPrint = (String? msg, {int? wrapWidth}) {
    if (msg != null) ctrl.add('${DateTime.now().toIso8601String()}  $msg\n');
  };
  return ctrl.stream;
})();
