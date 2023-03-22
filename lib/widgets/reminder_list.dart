import 'dart:convert';

import 'package:flutter/material.dart' hide Notification;

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/enums/day.dart';
import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/common/notification.dart';
import 'package:take_your_meds/common/notification_handler.dart';

import 'package:take_your_meds/widgets/reminder.dart';
import 'package:take_your_meds/widgets/cancel_button.dart';

class ReminderList extends StatefulWidget {
  const ReminderList({super.key});

  @override
  State<StatefulWidget> createState() => ReminderListState();
}

class ReminderListState extends State<ReminderList> {
  List<dynamic>? reminders;
  List<dynamic>? futureAlarms;

  @override
  void initState() {
    super.initState();
    fetchReminders();
    getAlarms();
  }

  Future<void> fetchReminders() async {
    List<dynamic> reminders = await Utils.fetchReminders();

    if (mounted) {
      setState(() {
        this.reminders = reminders;
      });
    }
  }

  Future<void> getAlarms() async {
    if (reminders == null) {
      await fetchReminders();
    }

    for (var reminder in reminders!) {
      if (reminder["enabled"] == false) {
        continue;
      }

      await sheduleReminder(reminder);
    }
  }

  Future<bool> sheduleReminder(reminder) async {
    String? timeString = reminder["time"];
    DateTime time =
        timeString != null ? DateTime.parse(timeString) : DateTime.now();

    String? medName;
    if (reminder["med_uid"] != null) {
      List<dynamic> medsJson = await Utils.fetchMeds();
      dynamic med = medsJson.firstWhere(
        (med) => med["uid"] == reminder["med_uid"],
        orElse: () => null,
      );

      if (med != null) {
        medName = "${med["name"]} ${med["dose"]} x ${med["unit"]}";
      }
    }

    String title = "med_reminder".tr();
    String body = "reminder_take".tr(args: [medName ??= "medication".tr()]);

    if (medName != "medication".tr()) {
      body += "\n ${"tap_to_add_to_summary".tr()}";
    }

    // Includes false and null
    if (reminder["recurrent"] != true) {
      Notification notification = Notification(
        title,
        body,
        time: time,
        payload: reminder["med_uid"],
      );
      NotificationHandler.showNotification(notification);
      return false;
    }

    List<Day> days = [];

    // Construct day array
    Map<String, dynamic> reminderDays = reminder["days"];

    for (MapEntry entryDay in reminderDays.entries) {
      if (entryDay.value == true) {
        days.add(Day.fromString(entryDay.key)!);
      }
    }

    Notification notification = Notification(
      title,
      body,
      time: time,
      days: days,
      payload: reminder["med_uid"],
    );

    NotificationHandler.showPeriodicNotification(notification);
    return true;
  }

  void switchSave(newVal, element, {bool? isRecurrent}) {
    setState(() {
      element["enabled"] = newVal;
    });

    if (isRecurrent == false) {
      DateTime now = DateTime.now();
      DateTime time = DateTime.parse(element["time"]);
      DateTime updatedT = DateTime(
        now.year,
        now.month,
        now.day + 1,
        time.hour,
        time.minute,
        time.second,
      );

      element["time"] = updatedT.toIso8601String();
    }

    replaceReminder(element, element);
  }

  void replaceReminder(newVal, element) async {
    int i = reminders!.indexOf(element);
    reminders![i] = newVal;

    // Reschedule reminder
    sheduleReminder(newVal);

    await FileHandler.writeContent("reminders", jsonEncode(reminders!));
  }

  void showReminder(dynamic element) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Reminder(element)),
    );

    if (result == true) {
      deleteReminder(element);
    }

    if (result is Map) {
      // Update reminder
      replaceReminder(result, element);

      // Tell ui to rebuild
      if (mounted) {
        setState(() {});
      }
    }
  }

  void deleteReminder(dynamic element) async {
    bool? remove = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("del_reminder_title").tr(),
        content: const Text("del_reminder").tr(),
        actions: [
          const CancelButton(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("delete").tr(),
          ),
        ],
      ),
    );

    if (remove == null) {
      return;
    }

    if (remove) {
      reminders!.removeAt(reminders!.indexOf(element));

      if (mounted) {
        setState(() {});
      }

      await FileHandler.writeContent("reminders", jsonEncode(reminders!));
    }
  }

  List<Widget> generateElements(List<dynamic> json) {
    List<Widget> elements = [];
    elements.add(
      Center(
        child: const Text("reminders", style: TextStyle(fontSize: 25.0)).tr(),
      ),
    );

    for (var el in json) {
      bool isSwitched = el['enabled'];
      bool recurrent = el["recurrent"] ??= false;

      DateTime reminderTime = DateTime.parse(el['time']);
      bool isExpired = DateTime.now().isAfter(reminderTime);

      // If alarm is past now then disable
      if (!recurrent && isExpired) {
        isSwitched = false;
      }

      List<Widget> dayBtns = [];
      if (recurrent) {
        for (MapEntry<String, dynamic> entry in el["days"].entries) {
          String day = entry.key;
          bool enabled = entry.value;

          ButtonStyle style = ButtonStyle(
            padding: const MaterialStatePropertyAll(EdgeInsets.zero),
            minimumSize: const MaterialStatePropertyAll(Size.zero),
            fixedSize: const MaterialStatePropertyAll(Size(20, 20)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          );

          Widget t = enabled
              ? ElevatedButton(
                  onPressed: () {},
                  style: style,
                  child: Text(day.tr()[0]),
                )
              : TextButton(
                  onPressed: () {},
                  style: style,
                  child: Text(day.tr()[0]),
                );
          dayBtns.add(t);
        }
      }

      Widget row = SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        child: Wrap(children: dayBtns),
      );

      DateFormat dateFormat = DateFormat.Hm();
      if (!recurrent) {
        dateFormat.add_EEEE();
      }

      elements.add(
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          key: UniqueKey(),
          title: TextButton(
            onPressed: () => showReminder(el),
            onLongPress: () => deleteReminder(el),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.6,
                  child: Text(dateFormat.format(reminderTime)),
                ),
                row,
                Switch(
                  value: isSwitched,
                  onChanged: (_) => switchSave(_, el, isRecurrent: recurrent),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (elements.length == 1) {
      elements.add(Center(child: const Text("no_reminder").tr()));
    }

    return elements;
  }

  @override
  Widget build(BuildContext context) {
    if (reminders == null) {
      return const CircularProgressIndicator();
    }

    return ListView(children: generateElements(reminders!));
  }
}
