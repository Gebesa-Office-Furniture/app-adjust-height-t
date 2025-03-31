import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothController with ChangeNotifier {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  listenToAdapterState() {
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      notifyListeners();
    });
  }

  BluetoothAdapterState get adapterState => _adapterState;

  stopListeningToAdapterState() {
    _adapterStateStateSubscription.cancel();
  }
}
