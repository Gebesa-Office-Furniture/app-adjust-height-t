import 'dart:io';

import 'package:controller/src/controllers/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/user_api.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _notificationsEnabled = false;
  bool _permamentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndPreferences();
  }

  Future<void> _checkPermissionsAndPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled =
        prefs.getBool('sedentaryNotification') ?? false;

    final status = await Permission.notification.status;
    if (status.isGranted && notificationsEnabled) {
      setState(() {
        _notificationsEnabled = notificationsEnabled;
      });
    } else {
      setState(() {
        _notificationsEnabled = false;
      });
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _permamentlyDenied = true;
      });
    }
  }

  Future<void> setNoti(bool noti) async {
    final prefs = await SharedPreferences.getInstance();

    var height = prefs.getDouble('height') ?? 0;
    var weight = prefs.getDouble('weight') ?? 0;
    var language = prefs.getInt('language') ?? 1;
    var themeMode = prefs.getInt('themeMode') ?? 1;
    var unit = prefs.getInt('measurementUnit') ?? 0;

    prefs.setBool('sedentaryNotification', noti);

    await UserApi.updateUserData(
        unit, height, weight, noti, language, themeMode);
  }

  Future<void> _updatePreferences(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBlur(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.healthyReminders),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              if (_permamentlyDenied)
                GestureDetector(
                  onTap: () {
                    try {
                      if (Platform.isAndroid) {
                        openAppSettings();
                      } else {
                        //open settings ios
                        const OpenSettingsPlusIOS().appSettings();
                      }
                    } catch (e) {
                      rethrow;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.turnOnNotifications,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.sedenataryReminder,
                    style: const TextStyle(
                      fontSize: 18,
                    )),
                trailing: Switch(
                  value: _notificationsEnabled,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(.5),
                  onChanged: (value) async {
                    if (value) {
                      final status = await Permission.notification.request();
                      if (status.isPermanentlyDenied) {
                        try {
                          if (Platform.isAndroid) {
                            openAppSettings();
                          } else {
                            //open settings ios
                            const OpenSettingsPlusIOS().appSettings();
                          }
                        } catch (e) {
                          rethrow;
                        }
                      }
                      if (status.isGranted) {
                        await setNoti(value);
                        context
                            .read<AuthController>()
                            .initializeNotifications(context);
                        setState(() {
                          _notificationsEnabled = value;
                          _permamentlyDenied = false;
                        });
                        await _updatePreferences('notificationsEnabled', value);
                      }
                    } else {
                      await setNoti(value);
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      await _updatePreferences('notificationsEnabled', value);
                    }
                  },
                ),
              ),
              // ListTile(
              //   title: Text(AppLocalizations.of(context)!.sedenataryReminder,
              //       style: const TextStyle(
              //         fontSize: 18,
              //       )),
              //   trailing: Switch(
              //     inactiveThumbColor: Colors.grey,
              //     inactiveTrackColor: Colors.grey.withOpacity(.5),
              //     value: _sedentaryReminderEnabled,
              //     onChanged: (value) async {
              //       setState(() {
              //         _sedentaryReminderEnabled = value;
              //       });
              //       await _updatePreferences('sedentaryReminderEnabled', value);
              //     },
              //   ),
              // ),
            ],
          )),
    );
  }
}
