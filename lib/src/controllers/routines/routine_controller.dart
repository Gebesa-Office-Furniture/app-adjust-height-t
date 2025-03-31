import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:controller/src/api/routine_api.dart';
import 'package:controller/src/data/models/routine.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../api/error_handler.dart';
import '../../widgets/toast_service.dart';

class RoutineController extends ChangeNotifier {
  // Variables
  int hours = 0; // Custom hours
  int minutes = 0; // Custom minutes
  int totalSeconds = 0; // Total routine time in seconds
  Timer? _timer;
  int _remainingSeconds = 0; // Tiempo restante en segundos
  bool _isActive = false;

  bool isLoading = false;

  bool get isActive => _isActive;
  int get remainingSeconds => _remainingSeconds;

  Future getRoutineDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var inSeconds = prefs.getInt('routineDuration') ?? 0;
    //return 1h 30m format string
    String hours = (inSeconds ~/ 3600).toString();

    String minutes = ((inSeconds % 3600) ~/ 60).toString();

    return '${hours}h ${minutes}m';
  }

  // Set a custom routine duration
  void setCustomDuration(int seconds) {
    _remainingSeconds = seconds;
    notifyListeners();
  }

  //save the routine
  Future saveRoutine(BuildContext context, int seconds) async {
    try {
      _setLoading(true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int sedentatirsmNotification =
          prefs.getInt('sedentatirsmNotification') ?? 0;
      int id = prefs.getInt('routineId') ?? -1;
      final response = await RoutineApi.createUpdateRoutine(
          id, "routine", seconds, 1, sedentatirsmNotification);

      if (response['success']) {
        Routine routine = routineFromJson(response['data']);
        prefs.setInt('routineId', routine.result!.iId!);
        prefs.setInt('routineDuration', routine.result!.iDurationSeconds!);
        totalSeconds = routine.result!.iDurationSeconds!;
      } else {
        _setLoading(false);
        ToastService.showError(
            context,
            response['type'] != null
                ? ErrorHandler.getErrorMessage(response['type'], context)
                : json.decode(response['error'])['message']);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startRoutineApi(BuildContext context) async {
    try {
      _setLoading(true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int id = prefs.getInt('routineId') ?? -1;
      final response = await RoutineApi.startRoutine(id);

      if (response['success']) {
        log(response.toString());
        ToastService.showSuccess(
            context, AppLocalizations.of(context)!.routineStarted,
            alignment: Alignment.topCenter);
        startRoutine();
        return true;
      } else {
        ToastService.showError(
            context,
            response['type'] != null
                ? ErrorHandler.getErrorMessage(response['type'], context)
                : json.decode(response['error'])['message']);
        return false;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final durationInSeconds = prefs.getInt('routineDuration') ?? 0;

    // Guardar el inicio de la rutina y la duración
    prefs.setString('routineStartTime', now.toIso8601String());
    prefs.setInt('routineDuration', durationInSeconds);

    // Iniciar rutina
    _remainingSeconds = durationInSeconds;
    _isActive = true;
    _startTimer();

    notifyListeners();
  }

  Future<void> cancelRoutine(BuildContext context) async {
    try {
      _setLoading(true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int id = prefs.getInt('routineId') ?? -1;
      final response = await RoutineApi.stopRoutine(id);

      if (response['success']) {
        log(response.toString());
        stopRoutine();
      } else {
        ToastService.showError(
            context,
            response['type'] != null
                ? ErrorHandler.getErrorMessage(response['type'], context)
                : json.decode(response['error'])['message']);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRoutine() async {
    final prefs = await SharedPreferences.getInstance();

    final startTimeString = prefs.getString('routineStartTime');
    final duration = prefs.getInt('routineDuration');

    if (startTimeString != null && duration != null) {
      final startTime = DateTime.parse(startTimeString);
      final now = DateTime.now();

      // Calcular el tiempo transcurrido
      final elapsedSeconds = now.difference(startTime).inSeconds;

      // Si la rutina sigue activa
      if (elapsedSeconds < duration) {
        _remainingSeconds = duration - elapsedSeconds;
        _isActive = true;
        totalSeconds = duration;
        _startTimer();
      } else {
        _resetRoutine(); // Rutina completada
      }

      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        print(_remainingSeconds);
        notifyListeners();
      } else {
        _resetRoutine();
      }
    });
  }

  Future stopRoutine() async {
    _timer?.cancel();
    _resetRoutine();
    notifyListeners();
  }

  void checkAndCancelTimer() async {
    final prefs = await SharedPreferences.getInstance();

    // Recuperar la hora de inicio y duración desde SharedPreferences
    final routineStartTime =
        DateTime.parse(prefs.getString('routineStartTime') ?? '');
    final routineDuration = prefs.getInt('routineDuration') ?? 0;

    // Calcular tiempo restante
    final now = DateTime.now();
    final elapsedSeconds = now.difference(routineStartTime).inSeconds;
    final remainingSeconds = routineDuration - elapsedSeconds;

    // Verificar condiciones para cancelar el timer
    if (remainingSeconds <= 59 && now.minute != routineStartTime.minute) {
      print('Cancelling timer...');
      _timer?.cancel();
      _resetRoutine();
    } else {
      print('Timer still running...');
    }
  }

  void _resetRoutine() {
    _remainingSeconds = 0;
    _isActive = false;
    _timer?.cancel();
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
