import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityController with ChangeNotifier {
  bool _isConnected = true;
  late StreamSubscription _connectivitySubscription;

  ConnectivityController() {
    _initializeConnectivity();
  }

  bool get isConnected => _isConnected;

  void _initializeConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        _checkInternetAccess().then((isConnected) {
          _isConnected = isConnected;
          notifyListeners();
        });
        notifyListeners();
      },
    );
  }

  Future<bool> _checkInternetAccess() async {
    return await InternetConnection().hasInternetAccess;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
