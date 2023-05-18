import 'package:intl/intl.dart';
import 'package:take_your_meds/common/event.dart';
import 'package:take_your_meds/common/medication.dart';

class MedEvent implements Event {
  static final List<String> keys = [
    "quantity",
    "time",
    "date",
    "iso8601_date",
    "reason"
  ];
  static final List header = [...Medication.keys, ...MedEvent.keys];
  final int quantity;
  final DateTime _time;
  final String? reason;
  Medication medication;

  DateTime get datetime => _time;
  String get time => DateFormat.Hm().format(_time);
  String get uid => medication.uid;

  MedEvent(this.medication, this.quantity, this._time, this.reason);

  factory MedEvent.fromJson(
    Map<String, dynamic> json,
    int quantity,
    DateTime time,
    String? reason,
  ) {
    Medication med = Medication(
      json["name"],
      json["dose"] is String ? int.parse(json["dose"]) : json["dose"],
      json["unit"],
      json["notes"] ?? "/",
      json["uid"],
    );

    return MedEvent(
      med,
      quantity,
      time,
      reason,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> medicationObj = medication.toJson();
    medicationObj["time"] = time;
    medicationObj["date"] = DateFormat.yMd().format(_time);
    medicationObj["iso8601_date"] = _time.toIso8601String();
    medicationObj["quantity"] = quantity;
    medicationObj["reason"] = reason;
    return medicationObj;
  }

  @override
  String toCSV() {
    String csv = "";

    Map medToJson = toJson();
    medToJson.remove("uid");
    for (int i = 0; i < medToJson.length; i++) {
      if (medToJson[header[i]] != null) {
        csv += medToJson[header[i]] + ",";
      } else {
        csv += ",";
      }
    }
    csv += "\n";

    return csv;
  }

  Map<String, dynamic> toDBMap() {
    return {
      "date": _time.toIso8601String(),
      "quantity": quantity,
      "reason": reason,
      "med_uid": uid,
    };
  }
}
