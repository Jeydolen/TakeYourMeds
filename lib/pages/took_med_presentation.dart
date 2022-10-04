import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:take_your_meds/common/file_handler.dart';

class TookMedPresentationPage extends StatefulWidget {
  TookMedPresentationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TookMedPresentationPageState();
}

class TookMedPresentationPageState extends State<TookMedPresentationPage> {
  late Map json;
  DateTime now = DateTime.now();
  String today = DateFormat.Hm().add_EEEE().format(DateTime.now());
  TextEditingController quantityField = TextEditingController(text: "1");
  TextEditingController reasonField = TextEditingController(text: "/");

  void saveData() async {
    List<dynamic> a = jsonDecode(await FileHandler.readContent("meds") ?? "");

    Map<String, dynamic> cMed = a.firstWhere((e) => e["uid"] == json["uid"]);
    List<dynamic> dates = cMed["dates"] ?? [];

    dates.add({
      "date": now.toIso8601String(),
      "quantity": quantityField.text,
      "reason": reasonField.text
    });

    cMed["dates"] = dates;
    FileHandler.writeContent("meds", jsonEncode(a));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    json = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
        appBar: AppBar(
          title: Text("Took ${json["name"]}"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Text("Name: ${json["name"]}"),
              const SizedBox(height: 20),
              Text("Dosage: ${json["dose"]} ${json["unit"]}"),
              const SizedBox(height: 20),
              () {
                String? notes = json["notes"];
                String text = (notes == null || notes.isEmpty) ? "/" : notes;
                return Text("Notes: $text");
              }(),
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton(
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
                  SizedBox(width: 10),
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
              ElevatedButton(
                onPressed: saveData,
                child: const Text("Add to summary"),
              ),
            ],
          ),
        ));
  }
}
