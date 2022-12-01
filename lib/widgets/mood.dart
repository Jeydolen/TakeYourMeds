import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/mood_event.dart';
import 'package:take_your_meds/common/file_handler.dart';

class MoodsWidget extends StatefulWidget {
  const MoodsWidget({super.key});

  @override
  State<StatefulWidget> createState() => MoodsWidgetState();
}

class MoodsWidgetState extends State<MoodsWidget> {
  void saveMood(Mood mood) async {
    List<dynamic> currMoods = await Utils.fetchMoods();

    DateTime now = DateTime.now();
    dynamic obj = {
      "date": DateFormat.yMd().format(now),
      "time": DateFormat.Hm().format(now),
      "iso8601_date": now.toIso8601String(),
      "mood": mood.value,
      "mood_string": mood.string
    };

    currMoods.add(obj);
    await FileHandler.writeContent("moods", jsonEncode(currMoods));
  }

  Widget moodButton(Mood mood) => ElevatedButton(
        onPressed: () => saveMood(mood),
        style: ElevatedButton.styleFrom(
          backgroundColor: mood.moodColor,
        ),
        child: Text(mood.string).tr(),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Center(
          child: const Text("mood", style: TextStyle(fontSize: 25.0)).tr(),
        ),
        ...Mood.values.map((e) => moodButton(e)).toList()
      ],
    );
  }
}
