import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/widgets/time_button.dart';

class TookMedPresentationPage extends StatefulWidget {
  const TookMedPresentationPage({Key? key}) : super(key: key);

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
    Navigator.pop(context);

    List<dynamic> meds = await Utils.fetchMeds();

    Map<String, dynamic> cMed = meds.firstWhere((e) => e["uid"] == json["uid"]);
    List<dynamic> dates = cMed["dates"] ?? [];

    dates.add({
      "date": now.toIso8601String(),
      "quantity": quantityField.text,
      "reason": reasonField.text
    });

    cMed["dates"] = dates;
    FileHandler.writeContent("meds", jsonEncode(meds));

    Map<String, dynamic> lastTakenMed = {
      "name": "${cMed["name"]} ${cMed["dose"]}",
      "unit": cMed["unit"],
      "date": now.toIso8601String()
    };

    FileHandler.writeContent("last_taken", jsonEncode(lastTakenMed));

    if (cMed["favorite"] == true) {
      FileHandler.writeContent("last_favorite_taken", jsonEncode(lastTakenMed));
    }
  }

  @override
  Widget build(BuildContext context) {
    json = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
        appBar: AppBar(title: const Text("took_med").tr(args: [json["name"]])),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Text("med_name").tr(args: [json["name"]]),
              const SizedBox(height: 20),
              const Text("med_dosage").tr(args: [
                json["dose"],
                tr(json["unit"]),
              ]),
              const SizedBox(height: 20),
              const Text("med_notes").tr(args: [
                (json["notes"] == null || json["notes"].isEmpty)
                    ? "/"
                    : json["notes"]
              ]),
              const SizedBox(height: 20),
              Row(
                children: [
                  TimeButton(
                    onPressed: (DateTime newDate) {
                      setState(() {
                        now = newDate;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
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
                    child: const Text("change_day").tr(),
                  ),
                ],
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  decoration: InputDecoration(
                    label: const Text("quantity").tr(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: quantityField,
                ),
              ),
              SizedBox(
                width: 50,
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
            ],
          ),
        ));
  }
}
