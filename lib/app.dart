import 'dart:developer';

import 'package:flutter/material.dart' hide NavigationBar, Notification;

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/main.dart';
import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/enums/day.dart';
import 'package:take_your_meds/common/notification.dart';
import 'package:take_your_meds/common/notification_handler.dart';

import 'package:take_your_meds/pages/home.dart';
import 'package:take_your_meds/pages/misc.dart';
//import 'package:take_your_meds/pages/reminders.dart';

import 'package:take_your_meds/pages/summary.dart';
import 'package:take_your_meds/widgets/navigation_bar.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();

  static Future<bool> sheduleReminder(reminder) async {
    log("scheduling new reminder");
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
}

class _AppState extends State<App> {
  static int selectedId = 0;
  static final List<Widget> _pages = [
    const HomePage(),
    const SummaryPage(),
    // TODO: Fix this shit
    //const RemindersPage(),
    const MiscPage(),
  ];

  void change(int index) {
    setState(() {
      selectedId = index;
    });
  }

  void checkIfStartedFromNotification() async {
    var details = await flnp.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onSelectNotification(details.notificationResponse?.payload);
    }
  }

  Future<void> getAlarms() async {
    log("getting alarms");
    List reminders = await Utils.fetchReminders();

    await NotificationHandler.cancelAllNotifications();

    for (var reminder in reminders) {
      if (reminder["enabled"] != true) {
        // If alarm is disabled, check if alarm exist and delete it if thats the case
        // Easy solution might be to do
        // flnp.cancelAll(); and then creating reminders
        continue;
      }

      await App.sheduleReminder(reminder);
    }
  }

  @override
  void initState() {
    super.initState();

    checkIfStartedFromNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(selectedId),
      bottomNavigationBar: NavigationBar(onClick: change),
    );
  }
}
