import 'dart:io';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/day.dart';
import 'package:take_your_meds/common/mediastore.dart';
import 'package:take_your_meds/common/mood_event.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/widgets/cancel_button.dart';

class ImportExportWidget extends StatefulWidget {
  const ImportExportWidget({super.key});

  @override
  State<StatefulWidget> createState() => ImportExportWidgetState();
}

class ImportExportWidgetState extends State<ImportExportWidget> {
  void showSnackBar(Widget content) {
    final snack = SnackBar(content: content);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  void saveData(String data) async {
    Directory pDir = await getTemporaryDirectory();
    String fullPath = "${pDir.path}/data.json";
    FileHandler.saveToPath(fullPath, data);
    MediaStore.addItem(file: File(fullPath), name: "data.json");
  }

  void export() async {
    List<dynamic> meds = await Utils.fetchMeds();
    List<dynamic> moods = await Utils.fetchMoods();
    List<dynamic> reminders = await Utils.fetchReminders();

    Map<String, dynamic> allData = {
      "meds": meds,
      "moods": moods,
      "reminders": reminders,
    };

    // Duplicate of summary.saveData()
    saveData(jsonEncode(allData));
  }

  void import() async {
    dynamic json = await MediaStore.importItem();
    if (json == null || (json is! Map)) {
      if (mounted) {
        showSnackBar(const Text("This file use an invalid format"));
      }
      return;
    }

    // When valid, store in correct file
    bool doImport = await showWarningDialog();

    if (!doImport) {
      showSnackBar(const Text("Operation aborted !"));
      return;
    }

    if (json["meds"] != null) {
      // Meds data validation
      List<Map<String, dynamic>>? validMeds = validateMeds(json["meds"]);
      if (validMeds != null) {
        // Write to "meds" file
        FileHandler.writeContent("meds", jsonEncode(validMeds));
      }
    }

    if (json["moods"] != null) {
      // Moods data validation
      List<Map<String, dynamic>>? validMoods = validateMoods(json["moods"]);

      if (validMoods != null) {
        // Write to "meds" file
        FileHandler.writeContent("moods", jsonEncode(validMoods));
      }
    }

    if (json["reminders"] != null) {
      // Reminders data validation
      List<Map<String, dynamic>>? validReminders =
          validateReminders(json["reminders"]);

      if (validReminders != null) {
        // Write to "meds" file
        FileHandler.writeContent("reminders", jsonEncode(validReminders));
      }
    }
  }

  Future<bool> showWarningDialog() async {
    bool? doExport = await showDialog<bool>(
      context: context,
      builder: (BuildContext _) => StatefulBuilder(
        builder: ((context, setState) => AlertDialog(
              title:
                  const Text("Do you really want to import from this file ?"),
              content: const Text(
                  "Please note that this operation will replace application internal data"),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CancelButton(),
                    ElevatedButton(
                      child: const Text("Import"),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                )
              ],
            )),
      ),
    );

    if (doExport == null) {
      return false;
    }

    return doExport;
  }

  List<Map<String, dynamic>>? validateMeds(dynamic meds) {
    if (meds is! List<dynamic>) {
      return null;
    }

    List<Map<String, dynamic>> validMeds = [];
    for (dynamic el in meds) {
      if (el is! Map<String, dynamic>) {
        continue;
      }

      // Filter only valid elements
      // El that you cannot recreate
      if (el["name"] is String &&
          el["dose"] is String &&
          el["unit"] is String) {
        Map<String, dynamic> validEl = {
          "name": el["name"],
          "dose": el["dose"],
          "unit": el["unit"]
        };

        validEl["uid"] = el["uid"] is String ? el["uid"] : const Uuid().v4();
        validEl["notes"] = el["notes"] is String ? el["notes"] : "/";

        // Could validate all dates but i don't have time now
        // TODO: Validate all dates
        validEl["dates"] = el["dates"] is List ? el["dates"] : [];

        validMeds.add(validEl);
      }
    }

    return validMeds;
  }

  List<Map<String, dynamic>>? validateMoods(dynamic moods) {
    if (moods is! List<dynamic>) {
      return null;
    }

    List<Map<String, dynamic>> validMoods = [];
    for (dynamic el in moods) {
      if (el is! Map<String, dynamic>) {
        continue;
      }

      Map<String, dynamic> validEl = {};

      if (el["iso8601_date"] is String && el["mood"] is int) {
        validEl["mood"] = el["mood"];
        validEl["mood_string"] = Mood.getStringFromValue(el["mood"]);

        DateTime time = DateTime.parse(el["iso8601_date"]);

        validEl["time"] = DateFormat.Hm().format(time);
        validEl["date"] = DateFormat.yMd().format(time);
        validEl["iso8601_date"] = el["iso8601_date"];

        validMoods.add(validEl);
      }
    }
    return validMoods;
  }

  List<Map<String, dynamic>>? validateReminders(dynamic reminders) {
    if (reminders is! List<dynamic>) {
      return null;
    }

    List<Map<String, dynamic>> validReminders = [];
    for (dynamic el in reminders) {
      if (el is! Map<String, dynamic>) {
        continue;
      }

      Map<String, dynamic> validEl = {};

      if (el["time"] is String) {
        validEl["time"] = el["time"];

        if (el["med_name"] != null) {
          validEl["med_name"] = el["med_name"];
        }

        validEl["enabled"] = el["enabled"] is bool ? el["enabled"] : false;

        validEl["recurrent"] = false;
        if (el["recurrent"] == true) {
          if (el["days"] is Map<String, dynamic>) {
            Map<String, dynamic> days = el["days"];

            validEl["days"] = {};

            bool oneRecurr = false;
            for (Day day in Day.values) {
              if (days[day.string] is bool) {
                if (days[day.string] == true) {
                  oneRecurr = true;
                }

                validEl["days"][day.string] = days[day.string];
              } else {
                validEl["days"][day.string] = false;
              }
            }

            if (oneRecurr) {
              validEl["recurrent"] = true;
            }
          }
        }

        validReminders.add(validEl);
      }
    }
    return validReminders;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: import, child: Text("Import data")),
        TextButton(onPressed: export, child: Text("Export all data")),
      ],
    );
  }
}
