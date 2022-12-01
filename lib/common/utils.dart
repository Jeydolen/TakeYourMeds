import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/medication.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

List<DropdownMenuItem> generateDropDownItems(List<Medication> medications) =>
    medications
        .map(
          (element) => DropdownMenuItem<String>(
            value: element.uid,
            child: Text(element.name),
          ),
        )
        .toList();

class Utils {
  static Future<List<dynamic>> fetchFile(String fileName) async {
    String? jsonString = await FileHandler.readContent(fileName);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }

    return [];
  }

  static Future<List<dynamic>> fetchMeds() => fetchFile("meds");
  static Future<List<dynamic>> fetchMoods() => fetchFile("moods");
  static Future<List<dynamic>> fetchReminders() => fetchFile("reminders");

  static Future<List<MedEvent>> createEvents(List<dynamic> data) async {
    List<MedEvent> events = [];
    for (var element in data) {
      List<dynamic>? dates = element["dates"];
      if (dates != null) {
        for (var dateObj in dates) {
          DateTime date = DateTime.parse(dateObj["date"]);
          events.add(MedEvent.fromJson(
            element,
            dateObj["quantity"],
            date,
            dateObj["reason"]!,
          ));
        }
      }
    }
    return events;
  }
}
