import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:controller/src/controllers/user/user_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/settings/measurement_controller.dart';
import '../../widgets/backround_blur.dart';

class DeskSettingsScreen extends StatefulWidget {
  const DeskSettingsScreen({super.key});

  @override
  State<DeskSettingsScreen> createState() => _DeskSettingsScreenState();
}

class _DeskSettingsScreenState extends State<DeskSettingsScreen> {
  TextEditingController heightController = TextEditingController();

  TextEditingController weightController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadPhysicalData();
  }

  void _loadPhysicalData() async {
    var measurementController =
        Provider.of<MeasurementController>(context, listen: false);
    await measurementController.loadPreferences();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var height = prefs.getDouble('height') ?? 0;
    var weight = prefs.getDouble('weight') ?? 0;

    heightController.text = height.toStringAsFixed(2);
    weightController.text = weight.toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var measurementController = Provider.of<MeasurementController>(context);
    var userController = Provider.of<UserController>(context);

    return BackgroundBlur(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.physicalSettings),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          actions: [
            AsyncButtonBuilder(
              loadingWidget: SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 3,
                ),
              ),
              successWidget:
                  Icon(Icons.check, color: Theme.of(context).primaryColor),
              onPressed: () async {
                FocusScope.of(context).unfocus();

                var height = double.parse(heightController.text);
                var weight = double.parse(weightController.text);

                if (formKey.currentState!.validate()) {
                  userController.savePhysicalData(height, weight, context);
                  await Future.delayed(const Duration(seconds: 1));
                }
              },
              builder: (context, child, callback, _) {
                return TextButton(
                  onPressed: callback,
                  child: child,
                );
              },
              child: Text(AppLocalizations.of(context)!.save,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/settings/measurements')
                          .then(
                        (value) {
                          setState(() {
                            _loadPhysicalData();
                          });
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                  AppLocalizations.of(context)!.changeMeasure,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Airbnb',
                                  )),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.myHeight,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: heightController,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.startsWith('0')) {
                        return AppLocalizations.of(context)!.enterHeight;
                      }
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: false, decimal: false),
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: Text(
                              measurementController.getHeightUnitString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Airbnb',
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.myWeight,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: weightController,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.startsWith('0')) {
                        return AppLocalizations.of(context)!.enterWeight;
                      }
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: false, decimal: true),
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: Text(
                              measurementController.getWeightUnitString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Airbnb',
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
