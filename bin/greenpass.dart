import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:cbor/cbor.dart';
import 'package:dart_base45/dart_base45.dart';

class GreenPass {
  //Dati generici del greenpass
  String prefix = "HC1:";
  late String raw;
  late List<int> inflated;
  late Map payload;
  late bool isSuperGreenPass;

  //Dati generici della persona
  late String name;
  late String surname;
  late String dob;

  //Dati relativi al greenpass da vaccino
  late String vaccineType;
  late int doseNumber;
  late int totalSeriesOfDoses;
  late String dateOfVaccination;

  //Dati relativi al greenpass da test
  late String dateTimeOfSampleCollection;
  late String testResult;
  late String typeOfTest;
  late String ci;
  final testMolecular = "LP6464-4";

  //Dati relativi al greenpass da guarigione
  late String certificateValidFrom;
  late String certificateValidUntil;

  //Dati generici per il responso positivo o negativo
  final recoveryCertStartDay = "recovery_cert_start_day";
  final recoveryCertEndDay = "recovery_cert_end_day";
  final moleculaTestStartHour = "molecular_test_start_hours";
  final moleculaTestEndHour = "molecular_test_end_hours";
  final rapidTestStartHour = "rapid_test_start_hours";
  final rapidTestEndHour = "rapid_test_end_hours";
  final vaccineStartDayNotComplete = "vaccine_start_day_not_complete";
  final vaccineEndDayNotComplete = "vaccine_end_day_not_complete";
  final vaccineStartDayComplete = "vaccine_start_day_complete";
  final vaccineEndDayComplete = "vaccine_end_day_complete";
  final detected = "260373001";
  final notValidYet = "not valid yet";
  final valid = "valid";
  final notValid = "not_valid";
  final notGreenpass = "not_a_green pass";
  final partiallyValid = "valid only in Italy";

  //Regole per calcolare la scadenza del green pass dal link https://get.dgc.gov.it/v1/dgc/settings
  final rules = [
    {
      "name": "vaccine_end_day_complete",
      "type": "EU/1/20/1525",
      "value": "365"
    },
    {
      "name": "vaccine_start_day_complete",
      "type": "EU/1/20/1525",
      "value": "15"
    },
    {
      "name": "vaccine_end_day_not_complete",
      "type": "EU/1/20/1525",
      "value": "365"
    },
    {
      "name": "vaccine_start_day_not_complete",
      "type": "EU/1/20/1525",
      "value": "15"
    },
    {
      "name": "vaccine_end_day_complete",
      "type": "EU/1/21/1529",
      "value": "365"
    },
    {
      "name": "vaccine_start_day_complete",
      "type": "EU/1/21/1529",
      "value": "0"
    },
    {
      "name": "vaccine_end_day_not_complete",
      "type": "EU/1/21/1529",
      "value": "84"
    },
    {
      "name": "vaccine_start_day_not_complete",
      "type": "EU/1/21/1529",
      "value": "15"
    },
    {
      "name": "vaccine_end_day_complete",
      "type": "EU/1/20/1507",
      "value": "365"
    },
    {
      "name": "vaccine_start_day_complete",
      "type": "EU/1/20/1507",
      "value": "0"
    },
    {
      "name": "vaccine_end_day_not_complete",
      "type": "EU/1/20/1507",
      "value": "42"
    },
    {
      "name": "vaccine_start_day_not_complete",
      "type": "EU/1/20/1507",
      "value": "15"
    },
    {
      "name": "vaccine_end_day_complete",
      "type": "EU/1/20/1528",
      "value": "365"
    },
    {
      "name": "vaccine_start_day_complete",
      "type": "EU/1/20/1528",
      "value": "0"
    },
    {
      "name": "vaccine_end_day_not_complete",
      "type": "EU/1/20/1528",
      "value": "42"
    },
    {
      "name": "vaccine_start_day_not_complete",
      "type": "EU/1/20/1528",
      "value": "15"
    },
    {
      "name": "rapid_test_start_hours",
      "type": "GENERIC",
      "value": "0",
    },
    {
      "name": "rapid_test_end_hours",
      "type": "GENERIC",
      "value": "48",
    },
    {
      "name": "molecular_test_start_hours",
      "type": "GENERIC",
      "value": "0",
    },
    {
      "name": "molecular_test_end_hours",
      "type": "GENERIC",
      "value": "72",
    },
    {
      "name": "recovery_cert_start_day",
      "type": "GENERIC",
      "value": "0",
    },
    {
      "name": "recovery_cert_end_day",
      "type": "GENERIC",
      "value": "180",
    },
  ];

  Map decodeFromRaw(String code) {
    this.raw = code;
    Uint8List decodedBase45 =
        Base45.decode(this.raw.substring(this.prefix.length));
    inflated = ZLibDecoder().decodeBytes(decodedBase45);
    Cbor cbor = Cbor();
    cbor.decodeFromList(inflated);
    List<dynamic>? rawDecodification = cbor.getDecodedData();
    cbor.clearDecodeStack();
    cbor.decodeFromList(rawDecodification![0][2]);
    Map decodedData = Map<dynamic, dynamic>.from(cbor.getDecodedData()![0]);
    Map payload = Map<String, dynamic>.from(decodedData[-260][1]);

    if (payload.containsKey("r")) {
      this.ci = payload["r"].first["ci"];
      this.certificateValidFrom = payload["r"].first["df"];
      this.certificateValidUntil = payload["r"].first["du"];
      this.isSuperGreenPass = true;
    }
    if (payload.containsKey("v")) {
      this.vaccineType = payload["v"].first["mp"];
      this.doseNumber = payload["v"].first["dn"];
      this.dateOfVaccination = payload["v"].first["dt"];
      this.totalSeriesOfDoses = payload["v"].first["sd"];
      this.ci = payload["v"].first["ci"];
      this.isSuperGreenPass = true;
    }
    if (payload.containsKey("t")) {
      this.ci = payload["t"].first["ci"];
      this.dateTimeOfSampleCollection = payload["t"].first["sc"];
      this.testResult = payload["t"].first["tr"];
      this.typeOfTest = payload["t"].first["tt"];
      this.isSuperGreenPass = false;
    }

    this.dob = payload["dob"];
    this.name = payload["nam"]["gn"];
    this.surname = payload["nam"]["fn"];

    return payload;
  }

  getVaccineEndDayComplete(rules, vaccineType) {
    late var rule;
    for (int i = 0; i < rules.length; i++) {
      if (rules[i]["name"] == vaccineEndDayComplete &&
          rules[i]["type"] == vaccineType) {
        rule = rules[i];
      }
    }
    return rule;
  }

  getVaccineStartDayNotComplete(rules, vaccineType) {
    late var rule;
    for (int i = 0; i < rules.length; i++) {
      if (rules[i]["name"] == vaccineStartDayNotComplete &&
          rules[i]["type"] == vaccineType) {
        rule = rules[i];
      }
    }
    return rule;
  }

  getVaccineEndDayNotComplete(rules, vaccineType) {
    late var rule;
    for (int i = 0; i < rules.length; i++) {
      if (rules[i]["name"] == vaccineEndDayNotComplete &&
          rules[i]["type"] == vaccineType) {
        rule = rules[i];
      }
    }
    return rule;
  }

  getVaccineStartDayComplete(rules, vaccineType) {
    late var rule;
    for (int i = 0; i < rules.length; i++) {
      if (rules[i]["name"] == vaccineStartDayComplete &&
          rules[i]["type"] == vaccineType) {
        rule = rules[i];
      }
    }
    return rule;
  }

  getRecoveryCertStartDay(rules) {
    late var rule;
    for (int i = 0; i < rules.length; i++)
      if (rules[i]["name"] == recoveryCertStartDay) rule = rules[i];
    return rule;
  }

  getRecoveryCertEndDay(rules) {
    late var rule;
    for (int i = 0; i < rules.length; i++)
      if (rules[i]["name"] == recoveryCertEndDay) rule = rules[i];
    return rule;
  }

  int getRapidTestStartHour(rules) {
    late var rule;
    for (int i = 0; i < rules.length; i++)
      if (rules[i]["name"] == rapidTestStartHour) rule = rules[i];
    return int.parse(rule["value"]);
  }

  int getRapidTestEndHour(rules) {
    late var rule;
    for (int i = 0; i < rules.length; i++)
      if (rules[i]["name"] == rapidTestEndHour) rule = rules[i];
    return int.parse(rule["value"]);
  }

  int getMolecularTestStartHour(rules) {
    late var rule;
    for (int i = 0; i < rules.length; i++)
      if (rules[i]["name"] == moleculaTestStartHour) rule = rules[i];
    return int.parse(rule["value"]);
  }

  int getMolecularTestEndHour(rules) {
    late var rule;
    for (int i = 0; i < rules.length; i++)
      if (rules[i]["name"] == moleculaTestEndHour) rule = rules[i];
    return int.parse(rule["value"]);
  }

  Future<dynamic> validateTestGreenpass() async {
    String message = "";
    bool result = false;
    var now = DateTime.now();
    if (this.testResult == detected) {
      message = notValid;
    } else {
      try {
        var odtDateTimeOfCollection =
            DateTime.parse(dateTimeOfSampleCollection);
        DateTime startDate;
        DateTime endDate;

        if (typeOfTest == testMolecular) {
          startDate = odtDateTimeOfCollection
              .add(Duration(hours: getMolecularTestStartHour(rules)));
          endDate = odtDateTimeOfCollection
              .add(Duration(hours: getMolecularTestEndHour(rules)));
        } else {
          startDate = odtDateTimeOfCollection
              .add(Duration(hours: getRapidTestStartHour(rules)));
          endDate = odtDateTimeOfCollection
              .add(Duration(hours: getRapidTestEndHour(rules)));
        }

        if (startDate.isAfter(now)) {
          result = false;
          message = notValidYet;
        } else if (now.isAfter(endDate)) {
          result = false;
          message = notValid;
        } else {
          result = true;
          message = valid;
        }
      } catch (e) {
        result = false;
        message = notGreenpass;
      }
    }
    return {
      "result": result,
      "message": message,
    };
  }

  Future<dynamic> validateRecoveryGreenpass() async {
    var now = DateTime.now();
    String message = "";
    bool result = false;
    try {
      DateTime startDate = DateTime.parse(certificateValidFrom);
      DateTime endDate = DateTime.parse(certificateValidUntil);
      if (startDate.isAfter(now)) {
        message = notValidYet;
      } else if (now.isAfter(endDate)) {
        message = notValid;
      } else {
        result = true;
        message = valid;
      }
    } catch (e) {
      result = false;
      message = notValid;
    }
    return {
      "result": result,
      "message": message,
    };
  }

  Future<dynamic> validateVaccineGreenpass() async {
    var now = DateTime.now();
    String message = "";
    bool result = false;
    var rule = getVaccineEndDayComplete(this.rules, vaccineType);
    if (rule != null) {
      try {
        if (doseNumber < totalSeriesOfDoses) {
          var daysStart =
              getVaccineStartDayNotComplete(this.rules, vaccineType)["value"];
          var daysEnd =
              getVaccineEndDayNotComplete(this.rules, vaccineType)["value"];
          DateTime startDate = DateTime.parse(dateOfVaccination)
              .add(Duration(days: int.parse(daysStart)));
          DateTime endDate = DateTime.parse(dateOfVaccination)
              .add(Duration(days: int.parse(daysEnd)));
          if (startDate.isAfter(now)) {
            message = notValidYet;
          } else if (now.isAfter(endDate)) {
            message = notValid;
          } else {
            result = true;
            message = partiallyValid;
          }
        } else if (doseNumber >= totalSeriesOfDoses) {
          var daysStart =
              getVaccineStartDayComplete(this.rules, vaccineType)["value"];
          var daysEnd =
              getVaccineEndDayComplete(this.rules, vaccineType)["value"];
          DateTime startDate = DateTime.parse(dateOfVaccination)
              .add(new Duration(days: int.parse(daysStart)));
          DateTime.parse(dateOfVaccination)
              .add(new Duration(days: int.parse(daysEnd)));
          if (startDate.isAfter(now)) {
            message = notValidYet;
          } else {
            result = true;
            message = valid;
          }
        } else {
          message = notValid;
        }
      } catch (e) {
        message = notValid;
      }
    } else {
      message = notValid;
    }
    return {
      "result": result,
      "message": message,
    };
  }

  Future<dynamic> validateGreenpass(var payload) async {
    if (payload.containsKey("r")) {
      return validateRecoveryGreenpass();
    } else if (payload.containsKey("v")) {
      return validateVaccineGreenpass();
    } else if (payload.containsKey("t")) {
      return validateTestGreenpass();
    } else {
      return {"result": false, "message": notValid};
    }
  }
}
