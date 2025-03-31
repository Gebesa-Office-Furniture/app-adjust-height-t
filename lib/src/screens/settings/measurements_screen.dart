import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:provider/provider.dart';

import '../../controllers/settings/measurement_controller.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var measurementController = Provider.of<MeasurementController>(context);
    return BackgroundBlur(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.unitOfMeasure),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.metric,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.of(context)!.metricUnits),
              onTap: () {
                measurementController.setUnit(MeasurementUnit.metric);
              },
              trailing: measurementController.currentMeasurement ==
                      MeasurementUnit.metric
                  ? const Icon(Icons.check)
                  : null,
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.imperial,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.of(context)!.imperialUnits),
              onTap: () {
                measurementController.setUnit(MeasurementUnit.imperial);
              },
              trailing: measurementController.currentMeasurement ==
                      MeasurementUnit.imperial
                  ? const Icon(Icons.check)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
