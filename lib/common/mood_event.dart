import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:take_your_meds/common/event.dart';

enum Mood {
  good(string: "good", value: 1, moodColor: Colors.green),
  meh(string: "meh", value: 0, moodColor: Colors.orange),
  bad(string: "bad", value: -1, moodColor: Colors.red);

  const Mood({
    required this.string,
    required this.value,
    required this.moodColor,
  });
  final String string;
  final int value;
  final Color moodColor;
}

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
    Mood mood = Mood.values[json["mood"]];
    DateTime time = DateTime.parse(json["iso8601_date"]);
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
