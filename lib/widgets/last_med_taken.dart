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
  Widget lastFavoriteTaken = const SizedBox();

  @override
  void initState() {
    super.initState();
    initValues();
  }

  void initValues() async {
    Widget lastTakenWidget = await getLastTaken("last_taken") ?? SizedBox();
    Widget lastFavoriteWidget =
        await getLastTaken("last_favorite_taken") ?? SizedBox();
    setState(() {
      lastTaken = lastTakenWidget;
      lastFavoriteTaken = lastFavoriteWidget;
    });
  }

  Future<Widget?> getLastTaken(String filename) async {
    String? lastMedTaken = await FileHandler.readContent(filename);
    if (lastMedTaken == null) {
      return null;
    }

    dynamic jsonTaken = jsonDecode(lastMedTaken);
    if (jsonTaken is Map<String, dynamic>) {
      return Text(
        filename,
        style: const TextStyle(fontSize: 18),
      ).tr(args: [
        jsonTaken["name"] + " " + tr(jsonTaken["unit"]),
        DateFormat.Hm().format(DateTime.parse(jsonTaken["date"]))
      ]);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: lastTaken,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: lastFavoriteTaken,
      ),
    ]);
  }
}
