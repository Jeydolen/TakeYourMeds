import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:take_your_meds/widgets/cancel_button.dart';
import 'package:take_your_meds/widgets/reminder.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:take_your_meds/main.dart';
import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/file_handler.dart';

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
    //List<dynamic> reminders = await Utils.fetchReminders();

    for (var element in reminders!) {
      if (element["enabled"]) {
        String? time = element["time"];
        DateTimeComponents? d;

        if (element["recurrent"]) {
          if (element["all_days"] != null && element["all_days"]) {
            d = DateTimeComponents.time;
          } else {
            showNotificationForDay(element);
          }
        }

        showNotification(
          "med_reminder".tr(),
          "reminder_take".tr(args: [element["med_name"] ??= "medication".tr()]),
          time,
          d,
        );
      }
    }

    //return reminders;
  }

  void showNotificationForDay(jsonEl) {
    int weekday = 0;
    // Source: https://github.com/ThangVuNguyenViet/clock_app/blob/e87d2548a5890560d07b8d5f89bd1a0119d3707d/lib/providers/alarm_provider.dart
    for (bool day in jsonEl["days"].values) {
      weekday += 1;

      if (day) {
        DateTimeComponents d = DateTimeComponents.dayOfWeekAndTime;
        DateTime dt = DateTime.parse(jsonEl["time"]);
        String newTime = tz.TZDateTime.local(
          dt.year,
          dt.month,
          dt.day - dt.weekday + weekday,
          dt.hour,
          dt.minute,
        ).toIso8601String();

        showNotification(
          "med_reminder".tr(),
          "reminder_take".tr(args: [jsonEl["med_name"] ??= "medication".tr()]),
          newTime,
          d,
        );
      }
    }
  }

  void showNotification(
    String title,
    String body,
    String? time,
    DateTimeComponents? d,
  ) {
    time ??= DateTime.now().toIso8601String();

    try {
      DateTime.parse(time);
    } on Exception catch (_) {
      return;
    }

    DateTime dtn = DateTime.now().subtract(const Duration(seconds: 1));
    DateTime pdt = DateTime.parse(time);
    if (dtn.isAfter(pdt) && d == null) {
      return;
    }

    const AndroidNotificationDetails aND = AndroidNotificationDetails(
      'com.jeydolen.take_your_meds',
      'User reminder',
    );
    const NotificationDetails nD = NotificationDetails(android: aND);

    flnp.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.parse(tz.local, time).add(const Duration(seconds: 1)),
      nD,
      androidAllowWhileIdle: false,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: d,
    );
  }

  void switchSave(newVal, element, {bool? isRecurrent}) async {
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
    await FileHandler.writeContent("reminders", jsonEncode(reminders!));
    /*
    int i = (await futureAlarms).indexOf(element);
    (await futureAlarms)[i] = newVal;
    await FileHandler.writeContent("reminders", jsonEncode(await futureAlarms));
    */
  }

  void showReminder(dynamic element) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            Reminder(element as Map<String, dynamic>),
      ),
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

      FileHandler.writeContent("reminders", jsonEncode(reminders!));
    }
  }

  List<Widget> generateElements(List<dynamic> json) {
    return json.map(
      (el) {
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

        return ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          key: UniqueKey(),
          title: TextButton(
            onPressed: () => showReminder(el),
            onLongPress: () => deleteReminder(el),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.6,
                  child: Text(
                    DateFormat.Hm().add_EEEE().format(reminderTime),
                  ),
                ),
                row,
                Switch(
                  value: isSwitched,
                  onChanged: (_) => switchSave(_, el, isRecurrent: recurrent),
                )
              ],
            ),
          ),
        );
      },
    ).toList();
  }

  Widget listAlarms(List json) {
    List<Widget> els = generateElements(json);

    if (els.isEmpty) {
      return const Text("no_reminder").tr();
    }

    return SizedBox(
      // Full 2 recurrent reminder size
      height: MediaQuery.of(context).size.height / 2.5,
      width: MediaQuery.of(context).size.width,
      child: ListView(children: els),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (reminders == null) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        Center(
          child: const Text(
            "reminders",
            style: TextStyle(fontSize: 25.0),
          ).tr(),
        ),
        Wrap(
          children: [
            listAlarms(reminders!),
          ],
        )
      ],
    );
  }
}
