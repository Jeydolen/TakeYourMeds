import 'package:flutter/material.dart';
import 'package:take_your_meds/widgets/mood.dart';
import 'package:take_your_meds/widgets/reminder.dart';

class MiscPage extends StatefulWidget {
  const MiscPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MiscPageState();
}

class MiscPageState extends State<MiscPage> {
  void addAlarm() {
    // TODO: Update state on new Alarm
    Navigator.pushNamed(context, '/add_alarm');
  }

  @override
  Widget build(BuildContext context) {
    // Alarms + mood tracker
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: addAlarm,
            child: const Icon(Icons.add_alarm),
          ),
        ],
      ),
      body: ListView(children: const [ReminderList(), MoodsWidget()]),
    );
  }
}
