import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:controller/src/widgets/buttons/buttons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:provider/provider.dart';

import '../../controllers/desk/bluetooth_controller.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int currentPage = 0;
  PageController pageController = PageController();

  changeIndex(int newIndex) {
    currentPage = newIndex;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var bluetoothController = Provider.of<BluetoothController>(context);
    return BackgroundBlur(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Image.asset('assets/images/brand/logo.png', height: 30),
        ),
        extendBody: true,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: changeIndex,
                children: [
                  ConfigPage1(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 1),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                  ConfigPage2(
                    onAdapterStateChanged: (state) {
                      if (state == BluetoothAdapterState.on) {
                        HapticFeedback.lightImpact();
                        pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 1),
                          curve: Curves.easeIn,
                        );
                      } else {
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
                      }
                    },
                    adapterState: bluetoothController.adapterState,
                  ),
                  ConfigPage3(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      pageController.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 1),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                  FadeIn(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.microchip,
                                    size: 30,
                                    color: IconTheme.of(context).color),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Image.asset(
                                    'assets/images/desk/30.png',
                                    height: screenSize.height * 0.3,
                                    width: screenSize.width,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!
                                      .blueToothDeskInstalled,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                        PrincipalButton(
                          text: AppLocalizations.of(context)!.connect,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(context, '/scan');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (currentPage != 0)
              FadeIn(
                child: EasyStepper(
                  activeStep: currentPage - 1,
                  activeStepTextColor: Colors.black87,
                  finishedStepTextColor: Colors.black87,
                  internalPadding: 0,
                  showLoadingAnimation: false,
                  stepRadius: 8,
                  showStepBorder: false,
                  lineStyle: LineStyle(
                    lineType: LineType.normal,
                    activeLineColor: Colors.grey[300],
                    unreachedLineColor: Colors.grey[300],
                    unreachedLineType: LineType.normal,
                    finishedLineColor: Theme.of(context).primaryColor,
                  ),
                  steps: [
                    EasyStep(
                      customStep: CircleAvatar(
                        radius: 8,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: currentPage >= 1
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                      ),
                    ),
                    EasyStep(
                      customStep: CircleAvatar(
                        radius: 8,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: currentPage >= 2
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                        ),
                      ),
                      topTitle: true,
                    ),
                    EasyStep(
                      customStep: CircleAvatar(
                        radius: 8,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: currentPage >= 3
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                  onStepReached: (index) => setState(() => currentPage = index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ConfigPage3 extends StatelessWidget {
  const ConfigPage3({
    super.key,
    required this.onPressed,
  });

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return FadeIn(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.plugCircleCheck,
                    size: 30,
                    color: IconTheme.of(context).color,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 20),
                    child: Image.asset(
                      'assets/images/desk/30.png',
                      height: screenSize.height * 0.3,
                      width: screenSize.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.connectDeskTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
          PrincipalButton(
            text: AppLocalizations.of(context)!.next,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class ConfigPage2 extends StatefulWidget {
  const ConfigPage2({
    super.key,
    required this.onAdapterStateChanged,
    required this.adapterState,
  });

  final ValueChanged<BluetoothAdapterState> onAdapterStateChanged;

  final BluetoothAdapterState? adapterState;

  @override
  State<ConfigPage2> createState() => _ConfigPage2State();
}

class _ConfigPage2State extends State<ConfigPage2> {
  @override
  void initState() {
    super.initState();
    context.read<BluetoothController>().listenToAdapterState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var bluetoothController = Provider.of<BluetoothController>(context);
    return FadeIn(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  Expanded(
                      child: Center(
                    child: Container(
                      height: screenSize.height * 0.25,
                      width: screenSize.width * 0.3,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.bluetooth_audio,
                          color: IconTheme.of(context).color),
                    ),
                  )),
                ],
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    widget.adapterState == BluetoothAdapterState.on
                        ? AppLocalizations.of(context)!.bluetoothEnabled
                        : AppLocalizations.of(context)!.turnOnBluetooth,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
          PrincipalButton(
              text: widget.adapterState == BluetoothAdapterState.on
                  ? AppLocalizations.of(context)!.next
                  : AppLocalizations.of(context)!.enableBluetooth,
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onAdapterStateChanged(bluetoothController.adapterState);
              }),
        ],
      ),
    );
  }
}

class StepCircle extends StatelessWidget {
  final bool isActive;
  const StepCircle({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 12.0 : 8.0,
      height: isActive ? 12.0 : 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }
}

class ConfigPage1 extends StatelessWidget {
  const ConfigPage1({
    super.key,
    required this.onPressed,
  });

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                  child: Container(
                    height: screenSize.height * 0.25,
                    width: screenSize.width * 0.3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.bluetooth_audio,
                        color: IconTheme.of(context).color),
                  ),
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 20),
                    child: Image.asset(
                      'assets/images/desk/30.png',
                      height: screenSize.height,
                      width: screenSize.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.connectDeskTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.step1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.step2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        )),
        SafeArea(
            child: PrincipalButton(
          text: AppLocalizations.of(context)!.start,
          onPressed: onPressed,
        )),
        SizedBox(height: screenSize.height * 0.1),
      ],
    );
  }
}
