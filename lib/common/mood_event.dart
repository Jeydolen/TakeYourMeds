import 'package:intl/intl.dart';
import 'package:take_your_meds/common/event.dart';
import 'package:take_your_meds/common/enums/mood.dart';

class MoodEvent extends Event {
  static final List<String> headers = [
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
    Mood mood = Mood.values.firstWhere((el) => el.value == json["mood_int"]);
    DateTime time = DateTime.parse(json["date"]);
    return MoodEvent(mood, time);
  }

  @override
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
}
