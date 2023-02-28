import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:take_your_meds/common/file_handler.dart';

class LastMedTaken extends StatefulWidget {
  const LastMedTaken({super.key});

  @override
  State<StatefulWidget> createState() => LastMedTakenState();
}

class LastMedTakenState extends State<LastMedTaken> {
  Widget lastTaken = const SizedBox();

  @override
  void initState() {
    super.initState();
    getLastTaken();
  }

  void getLastTaken() async {
    String? lastMedTaken = await FileHandler.readContent("last_taken");
    if (lastMedTaken == null) {
      return;
    }

    dynamic jsonTaken = jsonDecode(lastMedTaken);
    if (jsonTaken is Map<String, dynamic>) {
      setState(() {
        lastTaken = const Text("last_med_taken").tr(args: [
          jsonTaken["name"],
          DateFormat.Hm().format(DateTime.parse(jsonTaken["date"]))
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return lastTaken;
  }
}
