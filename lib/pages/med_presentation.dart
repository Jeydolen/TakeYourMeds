import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:take_your_meds/common/file_handler.dart';

class MedPresentationPage extends StatefulWidget {
  Map<String, dynamic> json;

  MedPresentationPage({Key? key, required this.json}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MedPresentationPageState();
}

class MedPresentationPageState extends State<MedPresentationPage> {
  DateTime now = DateTime.now();
  String today = DateFormat.Hm().add_EEEE().format(DateTime.now());
  TextEditingController quantityField = TextEditingController(text: "1");
  TextEditingController reasonField = TextEditingController(text: "/");

  void saveData() async {
    List<dynamic> a = jsonDecode(await FileHandler.readContent("meds") ?? "");

    Map<String, dynamic> currentMed =
        a.firstWhere((el) => el["uid"] == widget.json["uid"]);

    List<dynamic> dates = currentMed["dates"] ?? [];

    dates.add({
      "date": now.toIso8601String(),
      "quantity": quantityField.text,
      "reason": reasonField.text
    });
    currentMed["dates"] = dates;
    FileHandler.writeContent("meds", jsonEncode(a));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Took ${widget.json["name"]}"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text("Name: ${widget.json["name"]}"),
          const SizedBox(height: 20),
          Text("Dosage: ${widget.json["dose"]} ${widget.json["unit"]}"),
          const SizedBox(height: 20),
          Text("Notes: ${widget.json["notes"] ?? "/"}"),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  TimeOfDay? tod = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(now),
                  );

                  if (tod != null) {
                    setState(() {
                      now = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        tod.hour,
                        tod.minute,
                      );
                    });
                  }
                },
                child: Text(DateFormat.Hm().add_EEEE().format(now)),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? dt = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2050),
                  );

                  if (dt != null) {
                    setState(() {
                      now = DateTime(
                        dt.year,
                        dt.month,
                        dt.day,
                        now.hour,
                        now.minute,
                      );
                    });
                  }
                },
                child: Text("Change day"),
              ),
            ],
          ),
          SizedBox(
            width: 50,
            child: TextField(
              decoration: InputDecoration(label: Text("Quantity")),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: quantityField,
            ),
          ),
          SizedBox(
            width: 50,
            child: TextField(
              decoration: InputDecoration(label: Text("Reason")),
              keyboardType: TextInputType.text,
              controller: reasonField,
            ),
          ),
          Center(
              child: ElevatedButton(
            onPressed: saveData,
            child: const Text("Add to summary"),
          )),
        ],
      ),
    );
  }
}
