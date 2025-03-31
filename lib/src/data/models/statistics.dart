// To parse this JSON data, do
//
//     final statistics = statisticsFromJson(jsonString);

import 'dart:convert';

Statistics statisticsFromJson(String str) =>
    Statistics.fromJson(json.decode(str));

String statisticsToJson(Statistics data) => json.encode(data.toJson());

class Statistics {
  Result? result;

  Statistics({
    this.result,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result?.toJson(),
      };
}

class Result {
  int? timeSeatedInSeconds;
  int? timeStandingInSeconds;
  int? timeMidInSeconds;
  double? caloriesBurned;
  String? memoriMoreUse;
  int? iCaloriesToBurnGoal;
  int? iSittingTimeSecondsGoal;
  int? iStandingTimeSecondsGoal;

  Result({
    this.timeSeatedInSeconds = 0,
    this.timeStandingInSeconds = 0,
    this.timeMidInSeconds = 0,
    this.caloriesBurned = 0,
    this.memoriMoreUse = '',
    this.iCaloriesToBurnGoal = 0,
    this.iSittingTimeSecondsGoal = 0,
    this.iStandingTimeSecondsGoal = 0,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        timeSeatedInSeconds: json["TimeSeatedInSeconds"] ?? 0,
        timeStandingInSeconds: json["TimeStandingInSeconds"] ?? 0,
        timeMidInSeconds: json["TimeMidInSeconds"] ?? 0,
        caloriesBurned: json["CaloriesBurned"] != null
            ? double.parse(json["CaloriesBurned"].toString())
            : 0,
        memoriMoreUse: json["MemoriMoreUse"] ?? '',
        iCaloriesToBurnGoal: json["iCaloriesToBurn_goal"] ?? 0,
        iSittingTimeSecondsGoal: json["iSittingTimeSeconds_goal"] ?? 0,
        iStandingTimeSecondsGoal: json["iStandingTimeSeconds_goal"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "TimeSeatedInSeconds": timeSeatedInSeconds,
        "TimeStandingInSeconds": timeStandingInSeconds,
        "TimeMidInSeconds": timeMidInSeconds,
        "CaloriesBurned": caloriesBurned,
        "MemoriMoreUse": memoriMoreUse,
        "iCaloriesToBurn_goal": iCaloriesToBurnGoal,
        "iSittingTimeSeconds_goal": iSittingTimeSecondsGoal,
        "iStandingTimeSeconds_goal": iStandingTimeSecondsGoal,
      };
}
