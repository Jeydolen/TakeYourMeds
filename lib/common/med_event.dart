import 'package:intl/intl.dart';
import 'package:take_your_meds/common/medication.dart';

enum SupportedFormats { JSON, CSV }

class MedEvent extends Medication {
  static final List<String> keys = ["quantity", "time", "reason"];
  static final List header = [...Medication.keys, ...MedEvent.keys];
  final String? quantity;
  final String? reason;
  final DateTime _time;

  String get time {
    return DateFormat.Hm().format(_time);
  }

  DateTime get datetime {
    return _time;
  }

  MedEvent(name, dose, unit, this.quantity, this._time, this.reason)
      : super(name, dose, unit);

  factory MedEvent.fromJson(Map<String, dynamic> json, DateTime time) {
    return new MedEvent(
      json["name"],
      json["dose"],
      json["unit"],
      json["quantity"],
      time,
      json["reason"],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> MedicationObj = Map.of(super.toJson());

    MedicationObj["time"] = time;
    MedicationObj["quantity"] = quantity;
    MedicationObj["reason"] = reason;
    return MedicationObj;
  }

  String toCSV() {
    String CSV = "";

    Map MedToJson = toJson();
    for (int i = 0; i < MedToJson.length; i++) {
      if (MedToJson[header[i]] != null) {
        CSV += MedToJson[header[i]] + ",";
      } else {
        CSV += ",";
      }
    }
    CSV += "\n";

    return CSV;
  }
}
