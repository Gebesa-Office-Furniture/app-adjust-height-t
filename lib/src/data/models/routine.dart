// To parse this JSON data, do
//
//     final routine = routineFromJson(jsonString);

import 'dart:convert';

Routine routineFromJson(String str) => Routine.fromJson(json.decode(str));

String routineToJson(Routine data) => json.encode(data.toJson());

class Routine {
  Result? result;

  Routine({
    this.result,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result?.toJson(),
      };
}

class Result {
  int? iId;
  int? iIdUser;
  String? sRoutineName;
  int? iDurationSeconds;
  DateTime? dtRegistrationDate;
  int? iStatus;

  Result({
    this.iId,
    this.iIdUser,
    this.sRoutineName,
    this.iDurationSeconds,
    this.dtRegistrationDate,
    this.iStatus,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        iId: json["iId"],
        iIdUser: json["iIdUser"],
        sRoutineName: json["sRoutineName"],
        iDurationSeconds: json["iDurationSeconds"],
        dtRegistrationDate: json["dtRegistrationDate"] == null
            ? null
            : DateTime.parse(json["dtRegistrationDate"]),
        iStatus: json["iStatus"],
      );

  Map<String, dynamic> toJson() => {
        "iId": iId,
        "iIdUser": iIdUser,
        "sRoutineName": sRoutineName,
        "iDurationSeconds": iDurationSeconds,
        "dtRegistrationDate": dtRegistrationDate?.toIso8601String(),
        "iStatus": iStatus,
      };
}
