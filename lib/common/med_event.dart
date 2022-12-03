import 'package:intl/intl.dart';
import 'package:take_your_meds/common/event.dart';
import 'package:take_your_meds/common/medication.dart';

class MedEvent extends Medication implements Event {
  static final List<String> keys = [
    "quantity",
    "time",
    "date",
    "iso8601_date",
    "reason"
  ];
  static final List header = [...Medication.keys, ...MedEvent.keys];
  final String quantity;
  final DateTime _time;
  final String? reason;

  DateTime get datetime => _time;
  String get time => DateFormat.Hm().format(_time);

  MedEvent(
    name,
    dose,
    unit,
    notes,
    uid,
    this.quantity,
    this._time,
    this.reason,
  ) : super(name, dose, unit, notes, uid);

  factory MedEvent.fromJson(
    Map<String, dynamic> json,
    String quantity,
    DateTime time,
    String? reason,
  ) {
    return MedEvent(
      json["name"],
      json["dose"],
      json["unit"],
      json["notes"] ?? "/",
      json["uid"],
      quantity,
      time,
      reason,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> medicationObj = Map.of(super.toJson());
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
}
