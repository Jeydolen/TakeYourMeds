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
      "mood": mood.string,
    };

    await DatabaseHandler().insert("moods", obj);
  }

  Widget moodButton(Mood mood, Color foregroundColor) {
    return ElevatedButton(
      onPressed: () => saveMood(mood),
      style: ElevatedButton.styleFrom(
        backgroundColor: mood.moodColor,
        foregroundColor: foregroundColor,
      ),
      child: Text(mood.string).tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Mood> moodValues = List.from(Mood.values);
    moodValues.remove(Mood.none);

    var brightness = MediaQuery.of(context).platformBrightness;
    Color foregroundColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;

    List<Widget> moods =
        moodValues.map((e) => moodButton(e, foregroundColor)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Center(
          child: const Text("mood", style: TextStyle(fontSize: 25.0)).tr(),
        ),
        ...moods,
      ],
    );
  }
}
