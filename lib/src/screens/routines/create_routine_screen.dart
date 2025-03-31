import 'package:async_button_builder/async_button_builder.dart';
import 'package:controller/routes/settings_routes.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:controller/src/widgets/buttons/buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/routines/routine_controller.dart';
import '../../widgets/dialogs/dialog_confirm.dart';
import '../../widgets/toast_service.dart';

class CreateRoutineModal extends StatefulWidget {
  const CreateRoutineModal({super.key});

  @override
  State<CreateRoutineModal> createState() => _CreateRoutineModalState();
}

class _CreateRoutineModalState extends State<CreateRoutineModal> {
  // Variable que guarda el tiempo seleccionado
  Duration _selectedTime = const Duration(hours: 0, minutes: 10);

  Key _pickerKey = UniqueKey();

  Duration lastSelectedTime = const Duration(hours: 0, minutes: 10);

  @override
  void initState() {
    super.initState();
    _setSelectedTime();
  }

  Future<bool> _validateWeightAndHeight() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double weight = prefs.getDouble('weight') ?? 0;
    double height = prefs.getDouble('height') ?? 0;
    if (weight == 0 || height == 0) {
      return false;
    }
    return true;
  }

  //validate if exists a routine in shared preferences
  Future<bool> _validateRoutine() async {
    if (_selectedTime.inSeconds == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future _validateMemories(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? m1 = prefs.getDouble('memory1');
    double? m2 = prefs.getDouble('memory2');
    double? m3 = prefs.getDouble('memory3');

    print(m1);
    print(m2);
    print(m3);

    String message = '${AppLocalizations.of(context)!.memoriesMissing}\n';

    if (m1 == null) {
      message += '${AppLocalizations.of(context)!.sitting}\n ';
    }
    if (m2 == null) {
      message += '${AppLocalizations.of(context)!.rest}\n';
    }
    if (m3 == null) {
      message += AppLocalizations.of(context)!.standing;
    }

    if (m1 != null && m2 != null && m3 != null) {
      return '';
    } else {
      //remove the last comma if exists
      if (message.endsWith('\n')) {
        message = message.substring(0, message.length - 1);
      }
    }

    //dialog to configure memories
    return message;
  }

  //set the selected time with shared preferences
  void _setSelectedTime() async {
    var routineController =
        Provider.of<RoutineController>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int seconds = prefs.getInt('routineDuration') ?? 600;
    routineController.setCustomDuration(seconds);
    setState(() {
      lastSelectedTime = Duration(seconds: seconds);
      _selectedTime = Duration(seconds: seconds);
      _pickerKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    var routineController = Provider.of<RoutineController>(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackgroundBlur(
          child: Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text(AppLocalizations.of(context)!.createRoutine),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close)),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)!.routineDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: CupertinoTimerPicker(
                      minuteInterval: 5,
                      key: _pickerKey,
                      initialTimerDuration: _selectedTime,
                      mode: CupertinoTimerPickerMode.hm,
                      onTimerDurationChanged: (value) {
                        setState(() {
                          _selectedTime = value;
                        });
                        routineController.setCustomDuration(value.inSeconds);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(AppLocalizations.of(context)!.shortcuts,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildRoutineButton(
                                  routineController,
                                  const Duration(minutes: 40),
                                  AppLocalizations.of(context)!.fortyMinutes,
                                ),
                              ),
                              Expanded(
                                child: _buildRoutineButton(
                                    routineController,
                                    const Duration(hours: 1),
                                    AppLocalizations.of(context)!.oneHour),
                              ),
                              Expanded(
                                child: _buildRoutineButton(
                                  routineController,
                                  const Duration(hours: 2),
                                  AppLocalizations.of(context)!.twoHours,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildRoutineButton(
                                  routineController,
                                  const Duration(hours: 3),
                                  AppLocalizations.of(context)!.threeHours,
                                ),
                              ),
                              Expanded(
                                child: _buildRoutineButton(
                                  routineController,
                                  const Duration(hours: 4),
                                  AppLocalizations.of(context)!.fourHours,
                                ),
                              ),
                              Expanded(
                                child: _buildRoutineButton(
                                  routineController,
                                  const Duration(hours: 8),
                                  AppLocalizations.of(context)!.eightHours,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RoundedButton(
                    isLoading: routineController.isLoading,
                    onPressed: () async {
                      bool valid = await _validateWeightAndHeight();
                      bool validRoutine = await _validateRoutine();
                      String memory = await _validateMemories(context);
                      if (memory != '') {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return DialogConfirm(
                                  icon: Icons.info,
                                  iconColor: Colors.red[100],
                                  title: AppLocalizations.of(context)!.wait,
                                  content: memory,
                                  confirmText:
                                      AppLocalizations.of(context)!.confirm,
                                  cancelText:
                                      AppLocalizations.of(context)!.cancel,
                                  onConfirm: () {
                                    Navigator.pop(context, true);
                                  },
                                  onCancel: () {});
                            });
                        return;
                      }
                      if (valid) {
                        if (validRoutine) {
                          FocusScope.of(context).unfocus();
                          var routineController =
                              Provider.of<RoutineController>(context,
                                  listen: false);

                          await routineController
                              .saveRoutine(context, _selectedTime.inSeconds)
                              .then((value) async {
                            await routineController
                                .startRoutineApi(context)
                                .then((val) {
                              if (val) {
                                Navigator.pop(context);
                                print("Routine started");
                              }
                            });
                          });
                        } else {
                          ToastService.showInfo(context,
                              AppLocalizations.of(context)!.invalidRoutine);
                        }
                      } else {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return DialogConfirm(
                                  icon: Icons.warning,
                                  iconColor: Colors.red[100],
                                  title: AppLocalizations.of(context)!.wait,
                                  content: AppLocalizations.of(context)!
                                      .configureHeightAndWeight,
                                  confirmText:
                                      AppLocalizations.of(context)!.configure,
                                  cancelText:
                                      AppLocalizations.of(context)!.cancel,
                                  onConfirm: () {
                                    Navigator.pop(context, true);
                                  },
                                  onCancel: () {});
                            }).then((value) {
                          if (value != null && value) {
                            Navigator.pushNamed(
                                context, SettingsRoutes.deskSettings);
                          }
                        });
                      }
                    },
                    text: AppLocalizations.of(context)!.initRoutine,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineButton(
      RoutineController routineController, Duration value, String label) {
    return RadioListTile<Duration>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      groupValue: _selectedTime,
      onChanged: (val) {
        routineController.setCustomDuration(_selectedTime.inSeconds);

        setState(() {
          _selectedTime = val!;
          _pickerKey = UniqueKey();
        });
      },
    );
  }
}
