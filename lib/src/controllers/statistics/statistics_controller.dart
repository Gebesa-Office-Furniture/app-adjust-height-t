import 'package:controller/src/api/statistics_api.dart';
import 'package:flutter/material.dart';
import '../../data/models/statistics.dart';

class StatisticsController extends ChangeNotifier {
  String dateFilter = 'Today';

  Statistics? statistics;

  bool _loading = false;
  bool _withoutData = false;

  bool get loading => _loading;
  bool get withoutData => _withoutData;

//get statistics
  Future<void> getStatistics(BuildContext context) async {
    _loading = true;
    _withoutData = false;

    notifyListeners();
    final response = await StatisticsApi.getStatistics(dateFilter);
    if (response['success']) {
      print(response['data']);
      statistics = statisticsFromJson(response['data']);
    } else {
      _withoutData = true;
    }
    _loading = false;
    notifyListeners();
  }

  //set date filter
  void setDateFilter(String filter) {
    dateFilter = filter;
    notifyListeners();
  }

  String formatDuration(int seconds) {
    final int hours = seconds ~/
        3600; // Divide los segundos entre 3600 para obtener las horas
    final int minutes = (seconds % 3600) ~/ 60; // Calcula los minutos restantes
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
