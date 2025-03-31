import 'dart:async';
import 'dart:io';
import 'package:controller/src/api/desk_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:controller/src/controllers/desk/desk_controller.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:controller/src/widgets/buttons/buttons.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../home/home_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  BluetoothAdapterState? _adapterState;
  final bool _isConnecting = false;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    try {
      _systemDevices.clear();
      // Verifica estado del adaptador Bluetooth
      showStatusBT();

      _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
        setState(() {
          _isScanning = scanning;
        });
      });

      // Suscripción a resultados del escaneo
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        _scanResults =
            results.where((r) => r.device.advName.isNotEmpty).toList();
        if (mounted) {
          setState(() {});
        }
      }, onError: (e) {
        if (mounted) {
          setState(() {});
        }
        print("Error en el escaneo: $e");
        showErrorDialog(AppLocalizations.of(context)!.allowPermissions);
      });
    } catch (e) {
      print("Error de permisos: $e");
      if (mounted) {
        setState(() {});
        showErrorDialog(AppLocalizations.of(context)!.allowPermissions);
      }
    }
  }

  Future<void> showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.permissions),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              try {
                if (Platform.isAndroid) {
                  openAppSettings();
                } else {
                  //open settings ios
                  const OpenSettingsPlusIOS().bluetooth();
                }
              } catch (e) {
                rethrow;
              }
            },
            child: Text(AppLocalizations.of(context)!.goToSettings),
          ),
        ],
      ),
    );
  }

  //show error connection dialog try again
  Future<void> showConnectionErrorDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.connectionError),
        content: Text(AppLocalizations.of(context)!.connectionErrorMessageBT),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    super.dispose();
  }

  Future showStatusBT() async {
    try {
      FlutterBluePlus.adapterState.listen((state) {
        if (mounted) {
          _adapterState = state;
          setState(() {});

          if (state == BluetoothAdapterState.on) {
            onScanPressed();
          }

          if (state == BluetoothAdapterState.off) {
            onStopPressed();
          }
        }
      });
    } catch (e) {
      print("Bluetooth Status Error: $e");
      showErrorDialog(AppLocalizations.of(context)!.allowPermissions);
    }
  }

  Future onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices([]);
    } catch (e) {
      print("System Devices Error: $e");
      showErrorDialog(AppLocalizations.of(context)!.allowPermissions);
    }
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        withServices: [
          Guid("ff12"),
        ],
      );
    } catch (e) {
      print("Start Scan Error: $e");
      // showErrorDialog(AppLocalizations.of(context)!.allowPermissions);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
      //clear scan results
      _scanResults.clear();
    } catch (e) {
      print("Stop Scan Error: $e");
    }
  }

  Future onConnectPressed(BluetoothDevice device) async {
    if (_isConnecting) {
      return;
    }
    showConnectingDialog();

    await Future.delayed(const Duration(milliseconds: 1000));

    DeskApi.registerDeskDevice(device.advName, device.remoteId.str, '1');

    await device.connect().catchError((e) {
      //hide dialog
      Navigator.of(context).pop();
      print("Error al conectar: $e");
      showConnectionErrorDialog();
    }).then((v) {
      //hide dialog
      Navigator.of(context).pop();
      context.read<DeskController>().setDevice(device);

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    });
  }

  //dialog connecting
  Future<void> showConnectingDialog() async {
    await showDialog(
      context: context,
      builder: (context) => SizedBox(
        child: AlertDialog(
          title: Center(child: Text(AppLocalizations.of(context)!.connecting)),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Evita que el diálogo se expanda.
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future onRefresh() async {
  //   if (_isScanning == false) {
  //     FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  //     _isScanning = true;
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  //   return Future.delayed(const Duration(milliseconds: 500));
  // }

  // List<Widget> _buildSystemDeviceTiles(BuildContext context) {
  //   return _systemDevices
  //       .map(
  //         (d) => SystemDeviceTile(
  //           device: d,
  //           onOpen: () => Navigator.of(context).pushReplacement(
  //             MaterialPageRoute(
  //               builder: (context) => const HomeScreen(),
  //             ),
  //           ),
  //           onConnect: () => onConnectPressed(d),
  //         ),
  //       )
  //       .toList();
  // }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () async {
              await onConnectPressed(r.device);
            },
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBlur(
      child: ScaffoldMessenger(
        child: Scaffold(
          //skip button
          floatingActionButton: _scanResults.isEmpty && !_isScanning
              ? FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Text(AppLocalizations.of(context)!.skip,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      )),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
            title: Text(AppLocalizations.of(context)!.findDevices,
                style: const TextStyle(
                  fontFamily: 'Airbnb',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            actions: <Widget>[
              if (_adapterState == BluetoothAdapterState.on && !_isScanning)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _initializeBluetooth,
                ),
            ],
          ),
          body: _isScanning
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.scanning,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : _adapterState == BluetoothAdapterState.off
                  ? Center(
                      child: PrincipalButton(
                          text: AppLocalizations.of(context)!.enableBluetooth,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            try {
                              if (Platform.isAndroid) {
                                FlutterBluePlus.turnOn();
                              } else {
                                //open settings ios
                                const OpenSettingsPlusIOS().bluetooth();
                              }
                            } catch (e) {
                              rethrow;
                            }
                          }),
                    )
                  : RefreshIndicator(
                      onRefresh: _initializeBluetooth,
                      backgroundColor: Theme.of(context).primaryColor,
                      color: Colors.white,
                      child: _scanResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.bluetooth,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .noDevicesFound,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 20),
                                  PrincipalButton(
                                    text: AppLocalizations.of(context)!
                                        .findDevices,
                                    onPressed: onScanPressed,
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              children: <Widget>[
                                // ..._buildSystemDeviceTiles(context),
                                ..._buildScanResultTiles(context),
                              ],
                            ),
                    ),
        ),
      ),
    );
  }
}

class ScanResultTile extends StatefulWidget {
  const ScanResultTile({super.key, required this.result, this.onTap});

  final ScanResult result;
  final VoidCallback? onTap;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  String getNiceManufacturerData(List<List<int>> data) {
    return data.map((val) => getNiceHexArray(val)).join(', ').toUpperCase();
  }

  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries
        .map((v) => '${v.key}: ${getNiceHexArray(v.value)}')
        .join(', ')
        .toUpperCase();
  }

  String getNiceServiceUuids(List<Guid> serviceUuids) {
    return serviceUuids.join(', ').toUpperCase();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.advName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.result.device.advName,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          // Text(
          //   widget.result.device.remoteId.str,
          //   style: Theme.of(context).textTheme.bodySmall,
          // )
        ],
      );
    } else {
      return Text(widget.result.device.remoteId.str);
    }
  }

  Widget _buildConnectButton(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.result.advertisementData.connectable
              ? Theme.of(context).primaryColor
              : Colors.grey,
          disabledBackgroundColor: Colors.grey.withOpacity(0.5),
        ),
        onPressed:
            (widget.result.advertisementData.connectable) ? widget.onTap : null,
        child: isConnected
            ? Text(AppLocalizations.of(context)!.open,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Airbnb',
                  fontSize: 16,
                ))
            : Text(
                widget.result.advertisementData.connectable
                    ? AppLocalizations.of(context)!.connect
                    : AppLocalizations.of(context)!.notConnectable,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Airbnb',
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var adv = widget.result.advertisementData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: _buildTitle(context),
          // leading: Text(widget.result.rssi.toString()),
          trailing: _buildConnectButton(context),
          // children: <Widget>[
          // if (adv.txPowerLevel != null)
          //   _buildAdvRow(context, 'Tx Power Level', '${adv.txPowerLevel}'),
          // if ((adv.appearance ?? 0) > 0)
          //   _buildAdvRow(
          //       context, 'Appearance', '0x${adv.appearance!.toRadixString(16)}'),
          // if (adv.msd.isNotEmpty)
          //   _buildAdvRow(
          //       context, 'Manufacturer Data', getNiceManufacturerData(adv.msd)),
          // if (adv.serviceUuids.isNotEmpty)
          //   _buildAdvRow(
          //       context, 'Service UUIDs', getNiceServiceUuids(adv.serviceUuids)),
          // if (adv.serviceData.isNotEmpty)
          //   _buildAdvRow(
          //       context, 'Service Data', getNiceServiceData(adv.serviceData)),
          // ],
        ),
      ),
    );
  }
}

class SystemDeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;
  final VoidCallback onConnect;

  const SystemDeviceTile({
    required this.device,
    required this.onOpen,
    required this.onConnect,
    super.key,
  });

  @override
  State<SystemDeviceTile> createState() => _SystemDeviceTileState();
}

class _SystemDeviceTileState extends State<SystemDeviceTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.device.advName),
      subtitle: Text(widget.device.remoteId.str),
      trailing: ElevatedButton(
        onPressed: isConnected ? widget.onOpen : widget.onConnect,
        child: isConnected ? const Text('OPEN') : const Text('CONNECT'),
      ),
    );
  }
}
