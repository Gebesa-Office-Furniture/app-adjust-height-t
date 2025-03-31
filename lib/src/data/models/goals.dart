// To parse this JSON data, do
//
//     final goals = goalsFromJson(jsonString);

import 'dart:convert';

Goals goalsFromJson(String str) => Goals.fromJson(json.decode(str));

String goalsToJson(Goals data) => json.encode(data.toJson());

class Goals {
  Results? results;

  Goals({
    this.results,
  });

  factory Goals.fromJson(Map<String, dynamic> json) => Goals(
        results:
            json["results"] == null ? null : Results.fromJson(json["results"]),
      );

  Map<String, dynamic> toJson() => {
        "results": results?.toJson(),
      };
}

class Results {
  int? iId;
  int? iIdUser;
  int? iStandingTimeSeconds;
  int? iSittingTimeSeconds;
  int? iCaloriesToBurn;
  DateTime? dtRegistrationDate;
  DateTime? dtModificationDate;

  Results({
    this.iId,
    this.iIdUser,
    this.iStandingTimeSeconds,
    this.iSittingTimeSeconds,
    this.iCaloriesToBurn,
    this.dtRegistrationDate,
    this.dtModificationDate,
  });

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        iId: json["iId"],
        iIdUser: json["iIdUser"],
        iStandingTimeSeconds: json["iStandingTimeSeconds"],
        iSittingTimeSeconds: json["iSittingTimeSeconds"],
        iCaloriesToBurn: json["iCaloriesToBurn"],
        dtRegistrationDate: json["dtRegistrationDate"] == null
            ? null
            : DateTime.parse(json["dtRegistrationDate"]),
        dtModificationDate: json["dtModificationDate"] == null
            ? null
            : DateTime.parse(json["dtModificationDate"]),
      );

  Map<String, dynamic> toJson() => {
        "iId": iId,
        "iIdUser": iIdUser,
        "iStandingTimeSeconds": iStandingTimeSeconds,
        "iSittingTimeSeconds": iSittingTimeSeconds,
        "iCaloriesToBurn": iCaloriesToBurn,
        "dtRegistrationDate": dtRegistrationDate?.toIso8601String(),
        "dtModificationDate": dtModificationDate?.toIso8601String(),
      };
}
