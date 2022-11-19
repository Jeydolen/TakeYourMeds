import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:take_your_meds/common/file_handler.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddReminderPageState();
}

class AddReminderPageState extends State<AddReminderPage> {
  DateTime now = DateTime.now();
  Map<String, bool> days = {
    "Mon": true,
    "Tue": false,
    "Wed": false,
    "Thu": false,
    "Fri": false,
    "Sat": false,
    "Sun": false,
  };
  bool recurrent = false;

  void saveData() async {
    dynamic obj = {
      "recurrent": recurrent,
      "time": now.toIso8601String(),
      "enabled": true
    };

    if (recurrent) {
      obj["days"] = days;
    }

    if (days.values.every((_) => _ == true)) {
      obj["all_days"] = true;
    }

    Navigator.pop(context, obj);

    String? alarms = await FileHandler.readContent("reminders");
    List<dynamic> currAlarms = alarms != null ? jsonDecode(alarms) : [];
    currAlarms.add(obj);
    await FileHandler.writeContent("reminders", jsonEncode(currAlarms));
  }

  Widget dayBtn(String text) {
    ButtonStyle style = ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      ),
    );

    if (!days[text]!) {
      return TextButton(
        onPressed: () {
          setState(() {
            days[text] = !days[text]!;
          });
        },
        style: style,
        child: Text(text),
      );
    }

    return ElevatedButton(
      onPressed: () {
        setState(() {
          days[text] = !days[text]!;
        });
      },
      style: style,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add reminder"),
      ),
      body: Column(
        children: [
          OutlinedButton(
            onPressed: () async {
              TimeOfDay? tod = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(now),
              );

              if (tod != null) {
                setState(() {
                  now = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    tod.hour,
                    tod.minute,
                  );
                });
              }
            },
            child: Text(DateFormat.Hm().format(now)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Recurrent'),
              Checkbox(
                value: recurrent,
                onChanged: ((value) {
                  setState(() {
                    recurrent = !recurrent;
                  });
                }),
              )
            ],
          ),
          recurrent
              ? Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    dayBtn('Mon'),
                    dayBtn('Tue'),
                    dayBtn('Wed'),
                    dayBtn('Thu'),
                    dayBtn('Fri'),
                    dayBtn('Sat'),
                    dayBtn('Sun'),
                  ],
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                saveData();
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
