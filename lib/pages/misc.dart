import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:take_your_meds/widgets/mood.dart';
import 'package:take_your_meds/widgets/import_export.dart';

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

  @override
  Widget build(BuildContext context) {
    // Alarms + mood tracker
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const Text("misc").tr(),
      ),
      body: ListView(
        children: const [
          MoodsWidget(),
          ImportExportWidget(),
        ],
      ),
    );
  }
}
