import 'dart:convert';

import 'package:controller/src/api/user_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/error_handler.dart';
import '../../widgets/toast_service.dart';

class UserController with ChangeNotifier {
  Future<bool> savePhysicalData(
      double height, double weight, BuildContext context) async {
    //update and save physical data in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final measurementSystem = prefs.getInt('measurementUnit') ?? 0;
    //  await prefs.setInt('language', user.user!.iIdLanguage ?? 1);
    // await prefs.setInt('themeMode', user.user!.iViewMode ?? 1);
    final language = prefs.getInt('language') ?? 1;
    final themeMode = prefs.getInt('themeMode') ?? 1;
    final sedentaryNotification =
        prefs.getBool('sedentaryNotification') ?? false;

    prefs.setInt('measurementUnit', measurementSystem);
    final response = await UserApi.updateUserData(measurementSystem, height,
        weight, sedentaryNotification, language, themeMode);
    if (response['success']) {
      await prefs.setDouble('height', height);
      await prefs.setDouble('weight', weight);
      notifyListeners();
      return true;
    } else {
      ToastService.showError(
          context,
          response['type'] != null
              ? ErrorHandler.getErrorMessage(response['type'], context)
              : json.decode(response['error'])['message']);
      return false;
    }
  }

  void clearPhysicalData() async {
    //clear physical data in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('height');
    await prefs.remove('weight');
    notifyListeners();
  }
}
