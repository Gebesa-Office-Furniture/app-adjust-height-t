// To parse this JSON data, do
//
//     final userResponse = userResponseFromJson(jsonString);

import 'dart:convert';

UserResponse userResponseFromJson(String str) =>
    UserResponse.fromJson(json.decode(str));

String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
  UserModel? user;
  Token? token;
  Token? refreshToken;

  UserResponse({
    this.user,
    this.token,
    this.refreshToken,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
        token: json["token"] == null ? null : Token.fromJson(json["token"]),
        refreshToken: json["refreshToken"] == null
            ? null
            : Token.fromJson(json["refreshToken"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "token": token?.toJson(),
        "refreshToken": refreshToken?.toJson(),
      };
}

class Token {
  String? result;
  int? expiresIn;

  Token({
    this.result,
    this.expiresIn,
  });

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        result: json["result"],
        expiresIn: json["expiresIn"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "expiresIn": expiresIn,
      };
}

class UserModel {
  int? id;
  String? name;
  String? email;
  int? idViewMode;
  String? viewMode;
  int? idLangague;
  String? language;
  double? weight;
  double? height;
  int? idMeasureType;
  String? measureType;
  List<ObjMemory>? objMemories;
  ObjRoutine? objRoutine;
  LastRoutine? lastRoutine;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.idViewMode,
    this.viewMode,
    this.idLangague,
    this.language,
    this.weight,
    this.height,
    this.idMeasureType,
    this.measureType,
    this.objMemories,
    this.objRoutine,
    this.lastRoutine,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["iId"],
        name: json["sName"],
        email: json["sEmail"],
        idViewMode: json["iViewMode"],
        viewMode: json["sViewMode"],
        idLangague: json["iIdLanguage"],
        language: json["sLanguage"],
        weight: json["dWeightKG"] == null
            ? 0
            : double.parse(json["dWeightKG"].toString()),
        height: json["dHeightM"] == null
            ? 0
            : double.parse(json["dHeightM"].toString()),
        idMeasureType: json["iMeasureType"],
        measureType: json["sMeasureType"],
        objMemories: json["objMemories"] is List
            ? List<ObjMemory>.from(
                (json["objMemories"] as List).map((x) => ObjMemory.fromJson(x)))
            : [],
        objRoutine: json["objRoutine"].isEmpty || json["objRoutine"] == {}
            ? null
            : ObjRoutine.fromJson(json["objRoutine"]),
        lastRoutine: json["lastRoutine"].isEmpty || json["lastRoutine"] == {}
            ? null
            : LastRoutine.fromJson(json["lastRoutine"]),
      );

  Map<String, dynamic> toJson() => {
        "iId": id,
        "sName": name,
        "sEmail": email,
        "iViewMode": idViewMode,
        "sViewMode": viewMode,
        "iIdLanguage": idLangague,
        "sLanguage": language,
        "dWeightKG": weight,
        "dHeightM": height,
        "iMeasureType": idMeasureType,
        "sMeasureType": measureType,
        "objMemories": List<dynamic>.from(objMemories!.map((x) => x.toJson())),
        "objRoutine": objRoutine?.toJson(),
        "lastRoutine": lastRoutine?.toJson(),
      };
}

class ObjMemory {
  int? iOrder;
  double? dHeightInch;

  ObjMemory({
    this.iOrder,
    this.dHeightInch,
  });

  factory ObjMemory.fromJson(Map<String, dynamic> json) => ObjMemory(
        iOrder: json["iOrder"],
        dHeightInch: double.parse(json["dHeightInch"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "iOrder": iOrder,
        "dHeightInch": dHeightInch,
      };
}

class LastRoutine {
  int? iId;
  String? sRoutineName;
  int? iDurationSeconds;
  DateTime? dtRegistrationDate;
  int? iStatus;

  LastRoutine({
    this.iId,
    this.sRoutineName,
    this.iDurationSeconds,
    this.dtRegistrationDate,
    this.iStatus,
  });

  factory LastRoutine.fromJson(Map<String, dynamic> json) => LastRoutine(
        iId: json["iId"],
        sRoutineName: json["sRoutineName"],
        iDurationSeconds: json["iDurationSeconds"],
        dtRegistrationDate: json["dtRegistrationDate"] == null
            ? null
            : DateTime.parse(json["dtRegistrationDate"]),
        iStatus: json["iStatus"],
      );

  Map<String, dynamic> toJson() => {
        "iId": iId,
        "sRoutineName": sRoutineName,
        "iDurationSeconds": iDurationSeconds,
        "dtRegistrationDate": dtRegistrationDate?.toIso8601String(),
        "iStatus": iStatus,
      };
}

class ObjRoutine {
  int? iId;
  int? iIdUser;
  int? iStatus;
  int? bCompleteRoutine;
  int? iDurationSecondsTarget;
  DateTime? dtStartDate;
  DateTime? dtEndDate;

  ObjRoutine({
    this.iId,
    this.iIdUser,
    this.iStatus,
    this.bCompleteRoutine,
    this.iDurationSecondsTarget,
    this.dtStartDate,
    this.dtEndDate,
  });

  factory ObjRoutine.fromJson(Map<String, dynamic> json) => ObjRoutine(
        iId: json["iId"],
        iIdUser: json["iIdUser"],
        iStatus: json["iStatus"],
        bCompleteRoutine: json["bCompleteRoutine"],
        iDurationSecondsTarget: json["iDurationSecondsTarget"],
        dtStartDate: json["dtStartDate"] == null
            ? null
            : DateTime.parse(json["dtStartDate"]),
        dtEndDate: json["dtEndDate"] == null
            ? null
            : DateTime.parse(json["dtEndDate"]),
      );

  Map<String, dynamic> toJson() => {
        "iId": iId,
        "iIdUser": iIdUser,
        "iStatus": iStatus,
        "bCompleteRoutine": bCompleteRoutine,
        "iDurationSecondsTarget": iDurationSecondsTarget,
        "dtStartDate": dtStartDate?.toIso8601String(),
        "dtEndDate": dtEndDate?.toIso8601String(),
      };
}
