import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:take_your_meds/common/database.dart';

import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/medication.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

List<DropdownMenuItem> generateDropdownItems(List<Medication> medications) =>
    medications
        .map(
          (element) => DropdownMenuItem<String>(
            value: element.uid,
            child: Text(element.name),
          ),
        )
        .toList();

bool isSameDay(DateTime a, DateTime b) {
  DateFormat dayPrecise = DateFormat.yMd();
  return dayPrecise.format(a) == dayPrecise.format(b);
}

bool isSameMonth(DateTime a, DateTime b) {
  DateFormat monthPrecise = DateFormat.yM();
  return monthPrecise.format(a) == monthPrecise.format(b);
}

class Utils {
  static Future<List<dynamic>> fetchFile(String fileName) async {
    String? jsonString = await FileHandler.readContent(fileName);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }

    return [];
  }

  static Future<List<dynamic>> fetchMeds() => DatabaseHandler()
      .selectAll("meds", orderBy: "order_int asc", where: "active = 1");

  static Future<List<dynamic>> fetchMoods() =>
      DatabaseHandler().selectAll("moods");
  static Future<List<dynamic>> fetchReminders() =>
      DatabaseHandler().selectAll("reminders");

  static List<MedEvent> createEvents(List<dynamic> data) {
    List<MedEvent> events = [];
    for (var element in data) {
      if (element["date"] == null) {
        continue;
      }

      DateTime date = DateTime.parse(element["date"]);

      dynamic qtyJson = element["quantity"];
      int quantity = qtyJson is int ? qtyJson : int.parse(qtyJson);

      events.add(MedEvent.fromJson(
        element,
        quantity,
        date,
        element["reason"]!,
      ));
    }
    return events;
  }
}
