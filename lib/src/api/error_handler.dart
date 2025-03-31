import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error, BuildContext context) {
    if (error is SocketException) {
      return AppLocalizations.of(context)!.socketException;
    } else if (error is TimeoutException) {
      return AppLocalizations.of(context)!.timeOutException;
    } else if (error is FormatException) {
      return AppLocalizations.of(context)!.formatException;
    } else if (error == "SESSION_EXPIRED") {
      return AppLocalizations.of(context)!.sessionExpired;
    } else {
      return AppLocalizations.of(context)!.unknownException;
    }
  }
}
