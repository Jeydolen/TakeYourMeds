import 'package:intl/intl.dart';

class MedEvent {
  final String name;
  final String? quantity;
  final String dose;
  final String unit;
  final DateTime? _time;

  String get time {
    return _time != null ? DateFormat.Hm().format(_time!) : "";
  }

  MedEvent(this.name, this.quantity, this.dose, this.unit, this._time);

  factory MedEvent.fromJson(Map<String, dynamic> json, DateTime time) {
    return new MedEvent(
      json["name"],
      json["quantity"],
      json["dose"],
      json["unit"],
      time,
    );
  }
}
