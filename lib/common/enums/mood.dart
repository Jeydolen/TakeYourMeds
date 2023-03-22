import 'package:flutter/material.dart';

enum Mood {
  none(string: "none", value: 999, moodColor: Colors.white),
  good(string: "good", value: 1, moodColor: Colors.green),
  meh(string: "meh", value: 0, moodColor: Colors.orange),
  bad(string: "bad", value: -1, moodColor: Colors.red);

  const Mood({
    required this.string,
    required this.value,
    required this.moodColor,
  });

  static String? getStringFromValue(int value) {
    Mood mood = Mood.fromValue(value);

    if (mood == Mood.none) {
      return null;
    }

    return mood.string;
  }

  static Mood fromValue(int value) {
    Mood mood = Mood.values.firstWhere(
      (element) => element.value == value,
      orElse: () => Mood.none,
    );

    return mood;
  }

  final String string;
  final int value;
  final Color moodColor;
}
