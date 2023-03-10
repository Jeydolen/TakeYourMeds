import 'package:flutter/material.dart';

import 'package:take_your_meds/widgets/mood.dart';
import 'package:take_your_meds/widgets/import_export.dart';
import 'package:take_your_meds/widgets/reminder_list.dart';

class MiscPage extends StatefulWidget {
  const MiscPage({Key? key}) : super(key: key);

  static void reloadPage(BuildContext context) {
    context.findAncestorStateOfType<MiscPageState>()!.reloadPage();
  }

  @override
  State<StatefulWidget> createState() => MiscPageState();
}

class MiscPageState extends State<MiscPage> {
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
    // Alarms + mood tracker
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
      body: ListView(
        children: const [
          ReminderList(),
          MoodsWidget(),
          ImportExportWidget(),
        ],
      ),
    );
  }
}
