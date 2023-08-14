import 'package:flutter/material.dart';

import 'package:take_your_meds/widgets/reminder_list.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> {
  Key key = UniqueKey();

  void reloadPage() {
    setState(() {
      key = UniqueKey();
    });
  }

  void addReminder() async {
    var result = await Navigator.pushNamed(context, '/add_alarm');
    if (result != null) {
      reloadPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Alarms
    return Scaffold(
      key: key,
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: addReminder,
            child: const Icon(Icons.add_alarm),
          ),
        ],
      ),
      body: const ReminderList(),
    );
  }
}
