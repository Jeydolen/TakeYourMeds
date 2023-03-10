import 'package:flutter/material.dart' hide NavigationBar;
import 'package:take_your_meds/main.dart';
import 'package:take_your_meds/pages/home.dart';
import 'package:take_your_meds/pages/misc.dart';
import 'package:take_your_meds/pages/reminders.dart';

import 'package:take_your_meds/pages/summary.dart';
import 'package:take_your_meds/widgets/navigation_bar.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static int selectedId = 0;
  static final List<Widget> _pages = [
    const HomePage(),
    const SummaryPage(),
    const RemindersPage(),
    const MiscPage(),
  ];

  void change(int index) {
    setState(() {
      selectedId = index;
    });
  }

  void checkIfStartedFromNotification() async {
    var details = await flnp.getNotificationAppLaunchDetails();
    if (details!.didNotificationLaunchApp) {
      onSelectNotification(details.notificationResponse?.payload);
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
