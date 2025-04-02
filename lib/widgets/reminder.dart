import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/medication.dart';
import 'package:take_your_meds/widgets/time_button.dart';
import 'package:take_your_meds/widgets/delete_button.dart';

class Reminder extends StatefulWidget {
  const Reminder(this.reminder, {super.key});

  final Map<String, dynamic> reminder;

  @override
  State<StatefulWidget> createState() => ReminderState();
}

class ReminderState extends State<Reminder> {
  Widget view = const CircularProgressIndicator();
  late DateTime reminderTime;
  late bool recurrent;
  DateTime? time;
  Widget? dropdown;
  String currMed = "none";
  List<Medication>? medList;

  Map<String, bool> days = {
    "mon": true,
    "tue": false,
    "wed": false,
    "thu": false,
    "fri": false,
    "sat": false,
    "sun": false,
  };

  @override
  void initState() {
    super.initState();

    Map reminder = widget.reminder;
    reminderTime = DateTime.parse(reminder["time"]);
    recurrent = reminder["recurrent"];

    if (reminder["med_uid"] != null) {
      currMed = widget.reminder["med_uid"];
    }

    generateDropDown();
  }

  void saveData() {
    DateTime reminderTime = time ??= this.reminderTime;
    widget.reminder["time"] = reminderTime.toIso8601String();
  }

  void switchDay(String dayKey) {
    Map<String, dynamic> reminder = widget.reminder;

    setState(() {
      reminder["recurrent"] = true;
      reminder["days"][dayKey] = !reminder["days"][dayKey];
    });
  }

  void changeMed(medUid) {
    setState(() {
      currMed = medUid;
    });
    widget.reminder["med_uid"] = currMed;
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

    setState(() {
      medList = medications;
    });

    List<DropdownMenuItem> dropDownMeds = generateDropdownItems(medications);

    // Adding default value
    dropDownMeds.add(
      DropdownMenuItem<String>(value: 'none', child: const Text("none").tr()),
    );

    setState(() {
      dropdown = DropdownButtonFormField<dynamic>(
        value: currMed,
        onChanged: changeMed,
        items: dropDownMeds,
      );
    });
  }

  Widget showReminder() {
    Map<String, dynamic> reminder = widget.reminder;

    List<Widget> days = [];
    if (recurrent) {
      Map<String, dynamic> daysMap = reminder["days"] ??= this.days;
      for (MapEntry<String, dynamic> entry in daysMap.entries) {
        String day = entry.key;
        bool enabled = entry.value;

        ButtonStyle style = ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          ),
        );

        Widget t =
            enabled
                ? ElevatedButton(
                  onPressed: () => switchDay(day),
                  style: style,
                  child: Text(day.tr()),
                )
                : TextButton(
                  onPressed: () => switchDay(day),
                  style: style,
                  child: Text(day.tr()),
                );
        days.add(t);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * .1,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("${tr("medication").capitalize()} :"),
            dropdown ??= const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimeButton(
                  onPressed: (DateTime newTime) {
                    setState(() {
                      time = DateTime(
                        reminderTime.year,
                        reminderTime.month,
                        reminderTime.day,
                        newTime.hour,
                        newTime.minute,
                      );

                      reminderTime = time!;
                    });
                  },
                  initialTime: reminderTime,
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? dt = await showDatePicker(
                      context: context,
                      initialDate: time ??= reminderTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                    );

                    if (dt != null) {
                      setState(() {
                        time = DateTime(
                          dt.year,
                          dt.month,
                          dt.day,
                          reminderTime.hour,
                          reminderTime.minute,
                        );

                        reminderTime = time!;
                      });
                    }
                  },
                  child: const Text("change_day").tr(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text("recurrent").tr(),
              value: recurrent,
              onChanged: (value) {
                setState(() {
                  recurrent = !recurrent;
                  reminder["recurrent"] = recurrent;
                });
              },
            ),
            const SizedBox(height: 10),
            Wrap(alignment: WrapAlignment.center, children: days),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DeleteButton(),
                ElevatedButton(
                  onPressed: () {
                    saveData();
                    Navigator.pop(context, reminder);
                  },
                  child: const Text("save").tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String medName = widget.reminder["med_uid"] ??= "none";
    if (medList != null && medName != "none") {
      medName = medList!.firstWhere((element) => element.uid == medName).name;
    }

    if (medName == "none") {
      medName = "medication".tr();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("reminder_for").tr(args: [medName])),
      body: showReminder(),
    );
  }
}
