import 'package:controller/src/api/user_api.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MeasurementUnit { metric, imperial }

class MeasurementController with ChangeNotifier {
  static const String _unitKey = 'measurementUnit';

  // Unidad actual, por defecto es métrica
  MeasurementUnit _currentMeasurement = MeasurementUnit.metric;

  MeasurementController() {
    loadPreferences();
  }

  MeasurementUnit get currentMeasurement => _currentMeasurement;

  // Obtener unidad como cadena para mostrar en la UI
  String get currentMeasurementString =>
      _currentMeasurement == MeasurementUnit.metric ? "Metric" : "Imperial";

  // Cargar unidad desde SharedPreferences
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final unitIndex = prefs.getInt(_unitKey) ?? 1; // 0: metric, 1: imperial
    _currentMeasurement = MeasurementUnit.values[unitIndex];
    notifyListeners();
  }

  // Cambiar la unidad y guardar en SharedPreferences
  Future<void> setUnit(MeasurementUnit unit) async {
    if (unit == _currentMeasurement) return;

    _currentMeasurement = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unitKey, unit.index);

    //get height and weight from shared preferences
    var height = prefs.getDouble('height') ?? 0;
    var weight = prefs.getDouble('weight') ?? 0;

    //convert height and weight to the new unit
    if (unit == MeasurementUnit.metric) {
      height = inchesToCm(height);
      weight = lbsToKg(weight);
    } else {
      height = cmToInches(height);
      weight = kgToLbs(weight);
    }

    //save the new height and weight
    await prefs.setDouble('height', height);
    await prefs.setDouble('weight', weight);

    if (await InternetConnection().hasInternetAccess) {
      UserApi.updateUserData(unit.index, height, weight);
    }

    notifyListeners();
  }

  // Convertir pulgadas a centímetros sin redondear
  double inchesToCmDouble(double inches) {
    return (inches * 2.54).toDouble();
  }

  // Convertir centímetros a pulgadas
  double cmToInchesDouble(double cm) {
    return (cm / 2.54).toDouble();
  }

  // Convertir cualquier medida a milímetros
  double toMillimeters(double value) {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return value * 25.4; // Convertir pulgadas a mm
      case MeasurementUnit.metric:
        return value * 10; // Convertir cm a mm
    }
  }

  //get measurement string
  String getHeightUnitString() {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return "in";
      case MeasurementUnit.metric:
        return "cm";
    }
  }

  //get measurement unit kg or lb
  String getWeightUnitString() {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return "lb";
      case MeasurementUnit.metric:
        return "kg";
    }
  }

  // Obtener medida como cadena en la unidad actual
  String getMeasurementString(double value) {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return "${value.toStringAsFixed(0)} in";
      case MeasurementUnit.metric:
        return "${value.toStringAsFixed(0)} cm";
    }
  }

  //get height value current unit string
  String getHeightValueString(double value) {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return "${inchesToCm(value).toStringAsFixed(2)} cm";
      case MeasurementUnit.metric:
        return "${value.toStringAsFixed(2)} cm";
    }
  }

  //get weight value current unit string
  String getWeightValueString(double value) {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return "${(value * 0.453592).toStringAsFixed(2)} kg";
      case MeasurementUnit.metric:
        return "${value.toStringAsFixed(2)} kg";
    }
  }

  // Convertir centímetros a pulgadas
  double cmToInches(double cm) {
    return cm / 2.54;
  }

  // Convertir pulgadas a centímetros
  double inchesToCm(double inches) {
    return inches * 2.54;
  }

  // Convertir kilogramos a libras
  double kgToLbs(double kg) {
    return kg * 2.20462;
  }

  // Convertir libras a kilogramos
  double lbsToKg(double lbs) {
    return lbs / 2.20462;
  }

  // Obtener el valor de altura en la unidad actual
  double getHeightValue(double value) {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return cmToInches(value); // Convertir de cm a pulgadas
      case MeasurementUnit.metric:
        return value; // No convertir, ya está en cm
    }
  }

  // Obtener el valor de peso en la unidad actual
  double getWeightValue(double value) {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return kgToLbs(value); // Convertir de kg a libras
      case MeasurementUnit.metric:
        return value; // No convertir, ya está en kg
    }
  }

  // Convertir altura a métrico antes de guardar
  double convertHeightToMetric(double value) {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return inchesToCm(value); // Convertir de pulgadas a cm
      case MeasurementUnit.metric:
        return value; // No convertir, ya está en cm
    }
  }

  // Convertir peso a métrico antes de guardar
  double convertWeightToMetric(double value) {
    switch (_currentMeasurement) {
      case MeasurementUnit.imperial:
        return lbsToKg(value); // Convertir de libras a kg
      case MeasurementUnit.metric:
        return value; // No convertir, ya está en kg
    }
  }

  // Convertir una medida desde una unidad específica a la unidad actual
  double convertToCurrentUnit(double value) {
    if (_currentMeasurement == MeasurementUnit.metric) {
      return inchesToCm(value);
    } else if (_currentMeasurement == MeasurementUnit.imperial) {
      return value;
    }

    return value; // Caso por defecto (si es necesario)
  }
}
