import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:take_your_meds/common/mood_event.dart';
import 'package:take_your_meds/common/file_handler.dart';

class MoodsWidget extends StatefulWidget {
  const MoodsWidget({super.key});

  @override
  State<StatefulWidget> createState() => MoodsWidgetState();
}

class MoodsWidgetState extends State<MoodsWidget> {
  void saveMood(Mood mood) async {
    String? moods = await FileHandler.readContent("moods");
    List<dynamic> currMoods = moods != null ? jsonDecode(moods) : [];

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Mood',
            style: TextStyle(fontSize: 25.0),
          ),
        ),
        ElevatedButton(
            onPressed: () => saveMood(Mood.good),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Good')),
        ElevatedButton(
            onPressed: () => saveMood(Mood.meh),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Meh')),
        ElevatedButton(
            onPressed: () => saveMood(Mood.bad),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Bad')),
      ],
    );
  }
}
