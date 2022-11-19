import 'package:intl/intl.dart';

enum Mood {
  good(string: "Good", value: 1),
  meh(string: "Meh", value: 0),
  bad(string: "Bad", value: -1);

  const Mood({required this.string, required this.value});
  final String string;
  final int value;
}

class MoodEvent {
  static final List<String> header = [
    "mood",
    "mood_string",
    "date",
    "time",
    "iso8601_date",
  ];

  final Mood mood;
  final DateTime _time;

  MoodEvent(this.mood, this._time);

  factory MoodEvent.fromJson(Map<String, dynamic> json) {
    Mood mood = Mood.values[json["mood"]];
    DateTime time = DateTime.parse(json["iso8601_date"]);
    return MoodEvent(mood, time);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> obj = {
      "date": DateFormat.yMd().format(_time),
      "time": DateFormat.Hm().format(_time),
      "iso8601_date": _time.toIso8601String(),
      "mood": mood.value,
      "mood_string": mood.string
    };
    return obj;
  }

  String toCSV() {
    String csv = "";

    Map json = toJson();
    for (int i = 0; i < json.length; i++) {
      if (json[header[i]] != null) {
        csv += "${json[header[i]]},";
      } else {
        csv += ",";
      }
    }
    csv += "\n";

    return csv;
  }
}
