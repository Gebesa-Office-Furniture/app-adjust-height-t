import 'dart:convert';

import 'package:controller/src/api/goals_api.dart';
import 'package:controller/src/data/models/goals.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:controller/src/widgets/buttons/buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../api/error_handler.dart';
import '../../widgets/toast_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  TextEditingController timeSittingController = TextEditingController();
  TextEditingController timeStandingController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();

  Duration timeSitting = const Duration(hours: 0);
  Duration timeStanding = const Duration(hours: 0);
  int _calories = 200; // Valor inicial
  final int _minCalories = 50; // Límite mínimo
  final int _maxCalories = 1000; // Límite máximo

  bool _isLoading = false;
  bool _isFetching = true;

  String _formatDuration(Duration duration, BuildContext context) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours ${AppLocalizations.of(context)!.hours} $minutes ${AppLocalizations.of(context)!.minutes}';
    } else if (hours > 0) {
      return '$hours ${AppLocalizations.of(context)!.hours}';
    } else if (minutes > 0) {
      return '$minutes ${AppLocalizations.of(context)!.minutes}';
    } else {
      return '0 ${AppLocalizations.of(context)!.hours}';
    }
  }

  Future<void> _saveGoals() async {
    _isLoading = true;
    setState(() {});

    // Guardar los valores
    print(timeSitting.inSeconds);
    print(timeStanding.inSeconds);
    print(_calories);
    // Validar si todos los valores son mayores a 0
    if (timeSitting.inSeconds > 0 &&
        timeStanding.inSeconds > 0 &&
        _calories > 0) {
      // Guardar los valores
      final response = await GoalsApi.setGoals(
        timeSitting.inSeconds,
        timeStanding.inSeconds,
        _calories,
      );

      if (response['success']) {
        // Mostrar un mensaje de éxito
        ToastService.showSuccess(
            context, AppLocalizations.of(context)!.goalsSaved);
      } else {
        ToastService.showError(
            context,
            response['type'] != null
                ? ErrorHandler.getErrorMessage(response['type'], context)
                : json.decode(response['error'])['message']);
      }
    } else {
      // Mostrar un diálogo de error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: Icon(Icons.error, color: Colors.red[200]),
            title: Text(AppLocalizations.of(context)!.wait),
            content: Text(AppLocalizations.of(context)!.completeData),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.confirm),
              ),
            ],
          );
        },
      );
    }

    _isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getGoals();
  }

  Future getGoals() async {
    final response = await GoalsApi.getGoals();
    if (response['success']) {
      Goals? goals = goalsFromJson(response['data']);
      if (goals.results != null) {
        timeSitting = Duration(seconds: goals.results!.iSittingTimeSeconds!);
        timeStanding = Duration(seconds: goals.results!.iStandingTimeSeconds!);
        _calories = goals.results!.iCaloriesToBurn!;
        timeSittingController.text = _formatDuration(timeSitting, context);
        timeStandingController.text = _formatDuration(timeStanding, context);
        caloriesController.text = '$_calories cal';
      }
    }
    _isFetching = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBlur(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.goals),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isFetching
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.timeSitQuestion,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.dataPerDay,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .color!
                                .withOpacity(0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            //open bottom dialog cupertino time picker
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SizedBox(
                                    height: 200,
                                    child: CupertinoTimerPicker(
                                      initialTimerDuration: timeSitting,
                                      mode: CupertinoTimerPickerMode.hm,
                                      onTimerDurationChanged: (duration) {
                                        timeSitting = duration;
                                        //validate hours and minutes higher than 0
                                        if (duration.inHours > 0 ||
                                            duration.inMinutes > 0) {
                                          timeSitting = duration;
                                        } else {
                                          timeSitting =
                                              const Duration(hours: 0);
                                        }
                                        timeSittingController.text =
                                            _formatDuration(
                                                timeSitting, context);
                                      },
                                    ),
                                  );
                                });
                          },
                          child: TextFormField(
                            enabled: false,
                            //change disabled text color
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color,
                              fontWeight: FontWeight.bold,
                            ),
                            controller: timeSittingController,
                            decoration: InputDecoration(
                              hintText:
                                  '0 ${AppLocalizations.of(context)!.hours}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.timeStandQuestion,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.dataPerDay,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .color!
                                .withOpacity(0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            //open bottom dialog cupertino time picker
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SizedBox(
                                    height: 200,
                                    child: CupertinoTimerPicker(
                                      initialTimerDuration: timeStanding,
                                      mode: CupertinoTimerPickerMode.hm,
                                      onTimerDurationChanged: (duration) {
                                        timeStanding = duration;
                                        //validate hours and minutes higher than 0
                                        if (duration.inHours > 0 ||
                                            duration.inMinutes > 0) {
                                          timeStanding = duration;
                                        } else {
                                          timeStanding =
                                              const Duration(hours: 0);
                                        }
                                        timeStandingController.text =
                                            _formatDuration(
                                                timeStanding, context);
                                      },
                                    ),
                                  );
                                });
                          },
                          child: TextFormField(
                            enabled: false,
                            //change disabled text color

                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color,
                              fontWeight: FontWeight.bold,
                            ),
                            controller: timeStandingController,
                            decoration: InputDecoration(
                              hintText:
                                  '0 ${AppLocalizations.of(context)!.hours}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.caloriesQuestion,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.dataPerDay,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .color!
                                .withOpacity(0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Botón para disminuir
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _calories = (_calories - 50)
                                      .clamp(_minCalories, _maxCalories);
                                });
                              },
                            ),
                            // Input numérico
                            SizedBox(
                              width: 90,
                              child: TextField(
                                enabled: false,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .color,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSubmitted: (value) {
                                  final int? newCalories = int.tryParse(value);
                                  if (newCalories != null) {
                                    setState(() {
                                      _calories = newCalories.clamp(
                                          _minCalories, _maxCalories);
                                    });
                                  }
                                },
                                controller: TextEditingController(
                                  text: '$_calories cal',
                                ),
                              ),
                            ),
                            // Botón para aumentar
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _calories = (_calories + 50)
                                      .clamp(_minCalories, _maxCalories);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        RoundedButton(
                          isLoading: _isLoading,
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            //save goals
                            await _saveGoals();
                          },
                          text: AppLocalizations.of(context)!.saveGoals,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
