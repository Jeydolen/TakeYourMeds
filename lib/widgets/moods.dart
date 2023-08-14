import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/database.dart';
import 'package:take_your_meds/common/enums/mood.dart';

class MoodsWidget extends StatefulWidget {
  const MoodsWidget({super.key});

  @override
  State<StatefulWidget> createState() => MoodsWidgetState();
}

class MoodsWidgetState extends State<MoodsWidget> {
  void saveMood(Mood mood) async {
    DateTime now = DateTime.now();

    dynamic obj = {
      "date": now.toIso8601String(),
      "mood_int": mood.value,
      "mood": mood.string
    };

    await DatabaseHandler().insert("moods", obj);
  }

  Widget moodButton(Mood mood) {
    return ElevatedButton(
      onPressed: () => saveMood(mood),
      style: ElevatedButton.styleFrom(
        backgroundColor: mood.moodColor,
      ),
      child: Text(mood.string).tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Mood> moodValues = List.from(Mood.values);
    moodValues.remove(Mood.none);

    List<Widget> moods = moodValues.map((e) => moodButton(e)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Center(
          child: const Text("mood", style: TextStyle(fontSize: 25.0)).tr(),
        ),
        ...moods
      ],
    );
  }
}
