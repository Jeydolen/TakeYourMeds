import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/common/medication.dart';
import 'package:take_your_meds/common/utils.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddReminderPageState();
}

class AddReminderPageState extends State<AddReminderPage> {
  bool recurrent = false;
  DateTime now = DateTime.now();
  Widget dropDown = const CircularProgressIndicator();
  String currMed = 'none';
  Map<String, bool> days = {
    "mon": true,
    "tue": false,
    "wed": false,
    "thu": false,
    "fri": false,
    "sat": false,
    "sun": false,
  };

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

    if (currMed != 'none') {
      obj['med_name'] = currMed;
    }

    Navigator.pop(context, obj);

    List<dynamic> currAlarms = await Utils.fetchReminders();
    currAlarms.add(obj);
    FileHandler.writeContent("reminders", jsonEncode(currAlarms));
  }

  Widget dayBtn(String key) {
    ButtonStyle style = ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      ),
    );

    if (!days[key]!) {
      return TextButton(
        onPressed: () {
          setState(() {
            days[key] = !days[key]!;
          });
        },
        style: style,
        child: Text(key.tr()),
      );
    }

    return ElevatedButton(
      onPressed: () {
        setState(() {
          days[key] = !days[key]!;
        });
      },
      style: style,
      child: Text(key.tr()),
    );
  }

  void changeMed(dynamic val) {
    setState(() {
      currMed = val;
    });
  }

  void generateDropDown() async {
    List<dynamic> meds = await Utils.fetchMeds();

    List<Medication> medications = [];
    for (var element in meds) {
      medications.add(
        Medication(
          element["name"],
          element["dose"],
          element["unit"],
          element["notes"],
          element["uid"],
        ),
      );
    }

    List<DropdownMenuItem> dropDownMeds = medications
        .map((element) => DropdownMenuItem<String>(
              value: element.name,
              child: Text(element.name),
            ))
        .toList();

    // Adding default value
    dropDownMeds.add(DropdownMenuItem<String>(
      value: 'none',
      child: const Text("none").tr(),
    ));

    setState(() {
      dropDown = DropdownButtonFormField<dynamic>(
        value: currMed,
        onChanged: changeMed,
        items: dropDownMeds,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    // Load dropdown
    generateDropDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("add_reminder").tr()),
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
              const Text("recurrent").tr(),
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
          dropDown,
          recurrent
              ? Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    dayBtn("mon"),
                    dayBtn("tue"),
                    dayBtn("wed"),
                    dayBtn("thu"),
                    dayBtn("fri"),
                    dayBtn("sat"),
                    dayBtn("sun"),
                  ],
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                saveData();
              },
              child: const Text("submit").tr(),
            ),
          ),
        ],
      ),
    );
  }
}
