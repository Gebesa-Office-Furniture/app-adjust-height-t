import 'package:controller/src/screens/profile/delete_account.dart';
import 'package:flutter/material.dart';
import 'package:controller/src/screens/control/searching_devices_screen.dart';
import 'package:controller/src/screens/settings/desk_settings_screen.dart';
import 'package:controller/src/screens/settings/measurements_screen.dart';
import 'package:controller/src/screens/settings/preferences_screen.dart';
import 'package:controller/src/screens/settings/reminders_screen.dart';

import '../src/screens/profile/change_password.dart';
import '../src/screens/profile/profile_user.dart';
import '../src/screens/tutorial/tutorial_screen.dart';

class SettingsRoutes {
  static const String settings = '/settings';
  static const String accountSettings = '/settings/account';
  static const String changePassword = '/account/change-password';

  static const String tutorial = '/setup';
  static const String scarn = '/scan';
  static const String preferences = '/settings/preferences';
  static const String measurements = '/settings/measurements';
  static const String reminders = '/settings/reminders';
  static const String deskSettings = '/settings/deskSettings';
  static const String deleteAccount = '/settings/delete-account';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      accountSettings: (context) => const AccountSettingsScreen(),
      changePassword: (context) => ChangePasswordScreen(),
      preferences: (context) => const PreferencesScreen(),
      measurements: (context) => const MeasurementsScreen(),
      reminders: (context) => const RemindersScreen(),
      deskSettings: (context) => const DeskSettingsScreen(),
      // accountSettings: (context) => AccountSettingsScreen(),
      tutorial: (context) => const TutorialScreen(),
      scarn: (context) => const ScanScreen(),
      deleteAccount: (context) => const DeleteAccountScreen(),
    };
  }
}
