import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:take_your_meds/main.dart';
import 'package:take_your_meds/common/file_handler.dart';

class ReminderList extends StatefulWidget {
  const ReminderList({super.key});

  @override
  State<StatefulWidget> createState() => ReminderListState();
}

class ReminderListState extends State<ReminderList> {
  late Future<List<dynamic>> futureAlarms;

  @override
  void initState() {
    super.initState();
    futureAlarms = getAlarms();
  }

  Future<List<dynamic>> getAlarms() async {
    String? jsonString = await FileHandler.readContent("reminders");

    if (jsonString != null) {
      List<dynamic> alarms = jsonDecode(jsonString);

      for (var element in alarms) {
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

          const String title = 'Medication reminder';
          String body =
              'You should take your  ${element["notes"] ??= "medication"}';
          showNotification(title, body, time, d);
        }
      }

      return alarms;
    }

    return [];
  }

  void showNotificationForDay(jsonEl) {
    const String title = 'Medication reminder';
    String body = 'You should take your  ${jsonEl["notes"] ??= "medication"}';

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
        showNotification(title, body, newTime, d);
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

    flnp.zonedSchedule(0, title, body,
        tz.TZDateTime.parse(tz.local, time).add(const Duration(seconds: 1)), nD,
        androidAllowWhileIdle: false,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: d);
  }

  void switchSave(newVal, element) async {
    int i = (await futureAlarms).indexOf(element);

    setState(() {
      element['enabled'] = newVal;
    });

    (await futureAlarms)[i] = element;
    await FileHandler.writeContent("reminders", jsonEncode(await futureAlarms));
  }

  void updateAlarm(newVal, element) async {
    int i = (await futureAlarms).indexOf(element);

    setState(() {
      element['enabled'] = newVal;
    });

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

    (await futureAlarms)[i] = element;
    await FileHandler.writeContent("reminders", jsonEncode(await futureAlarms));
  }

  void deleteAlarm(element) async {
    bool? remove = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete alarm ?'),
        content:
            const Text('Are you sure you really want to delete this alarm ?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (remove == null) {
      return;
    }

    if (remove) {
      (await futureAlarms).removeAt((await futureAlarms).indexOf(element));
      setState(() {});
      FileHandler.writeContent("reminders", jsonEncode(await futureAlarms));
    }
  }

  List<Widget> generateElements(List<dynamic> json) => json.map(
        (el) {
          bool isSwitched = el['enabled'];
          bool recurrent = el["recurrent"] ??= false;
          bool isExpired = DateTime.now().isAfter(DateTime.parse(el['time']));

          // If alarm is past now then disable
          if (!recurrent && isExpired) {
            isSwitched = false;
          }

          List<Widget> b = [];
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
                      child: Text(day[0]),
                    )
                  : TextButton(
                      onPressed: () {},
                      style: style,
                      child: Text(day[0]),
                    );
              b.add(t);
            }
          }
          Widget row = SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Wrap(children: b),
          );

          return ListTile(
            contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            key: UniqueKey(),
            title: TextButton(
              onPressed: () {},
              onLongPress: () => deleteAlarm(el),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.6,
                    child: Text(
                      DateFormat.Hm().add_EEEE().format(
                            DateTime.parse(el['time']),
                          ),
                    ),
                  ),
                  row,
                  Switch(
                    value: isSwitched,
                    onChanged: recurrent
                        ? (_) => switchSave(_, el)
                        : (_) => updateAlarm(_, el),
                  )
                ],
              ),
            ),
          );
        },
      ).toList();

  Widget listAlarms(json) {
    List<Widget> els = generateElements(json);

    if (els.isEmpty) {
      return const SizedBox(
        child: Text('No reminders created yet.'),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.2,
      child: ListView(children: els),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureAlarms,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * .5,
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Reminders',
                    style: TextStyle(fontSize: 25.0),
                  ),
                ),
                listAlarms(snapshot.data),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}
