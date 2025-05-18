import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/database.dart';

class Alarm extends StatefulWidget {
  const Alarm({super.key, this.payload});

  final dynamic payload;

  @override
  State<StatefulWidget> createState() => AlarmState();
}

class AlarmState extends State<Alarm> {
  TextEditingController reasonField = TextEditingController(text: "Reminder");
  TextEditingController quantityField = TextEditingController(text: "1");
  Map<String, dynamic>? med;
  List<dynamic>? meds;
  bool _validate = false;

  void leavePage() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    if (widget.payload != null) {
      getMedFromUid(widget.payload);
    }
  }

  void saveData() async {
    if (quantityField.text.isEmpty) {
      setState(() {
        _validate = true;
      });
      return;
    }

    Map<String, dynamic> event = {
      "date": DateTime.now().toIso8601String(),
      "quantity": int.parse(quantityField.text),
      "reason": reasonField.text
    };

    event["med_uid"] = med!["uid"];
    DatabaseHandler().insert("events", event);

    if (mounted) {
      // Known bug: When Navigator.pop() is called main page is not updated
      // TODO: Fix
      leavePage();
    }
  }

  void getMedFromUid(String uid) async {
    // After full import replace by this:
    meds = await DatabaseHandler().selectAll("meds");

    med = meds!.firstWhere(
      (element) => element["uid"] == uid,
      orElse: () => null,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String title = "med_reminder".tr();
    List<Widget> rows = [
      const SizedBox(height: 20),
      const Text(
        "reminder_take",
        style: TextStyle(fontSize: 20),
      ).tr(args: ["medication".tr()]),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: leavePage,
        child: const Text("i_understand").tr(),
      ),
    ];

    if (med != null) {
      title = med!["name"];
      rows = [
        const SizedBox(height: 20),
        const Text("med_name").tr(args: [med!["name"]]),
        const SizedBox(height: 20),
        const Text("med_dosage").tr(args: [
          med!["dose"],
          tr(med!["unit"]),
        ]),
        const SizedBox(height: 20),
        const Text("med_notes").tr(args: [
          (med!["notes"] == null || med!["notes"].isEmpty) ? "/" : med!["notes"]
        ]),
        const SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * .8,
          child: TextField(
            decoration: InputDecoration(
              label: const Text("quantity").tr(),
              errorText: _validate ? "no_empty_value".tr() : null,
            ),
            keyboardType: TextInputType.number,
            controller: quantityField,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * .8,
          child: TextField(
            decoration: InputDecoration(label: const Text("reason").tr()),
            keyboardType: TextInputType.text,
            controller: reasonField,
          ),
        ),
        ElevatedButton(
          onPressed: saveData,
          child: const Text("add_summary").tr(),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }
}
