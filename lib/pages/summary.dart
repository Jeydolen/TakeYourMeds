import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' show join;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:take_your_meds/common/database.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/mediastore.dart';
import 'package:take_your_meds/common/mood_event.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/common/enums/supported_formats.dart';

import 'package:take_your_meds/pages/graphs.dart';

import 'package:take_your_meds/widgets/export_dialog.dart';
import 'package:take_your_meds/widgets/summary_calendar.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SummaryPageState();
}

class SummaryPageState extends State<SummaryPage> {
  late Future<List<MedEvent>> summary;
  late List<dynamic> json;
  bool addMoods = true;

  void showGraph() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GraphsPage()),
    );
  }

  Future<String> buildPath(String format) async {
    // Replace spaces and ":" because Windows is shit
    String now = DateTime.now()
        .toString()
        .replaceAll(" ", "_")
        .replaceAll(":", "-");
    Directory? pDir = await getApplicationDocumentsDirectory();

    if (!await pDir.exists()) {
      await pDir.create(recursive: true);
    }

    String fullPath = join(pDir.path, "${now}_summary.$format");
    return fullPath;
  }

  void saveData(String data, String format) async {
    String fullPath = await buildPath(format);
    FileHandler.saveToPath(fullPath, data);

    if (Platform.isAndroid) {
      MediaStore.addItem(
        file: File(fullPath),
        name: "${DateTime.now().toString()}_summary.$format",
      );
    }
  }

  void shareData(String data, String format) async {
    String fullPath = await buildPath(format);

    File(fullPath).writeAsString(data);
    Share.shareXFiles([XFile(fullPath)], subject: "My summary export");
  }

  String buildCSV(List<MedEvent> eventList, List<dynamic> moodsList) {
    // Exports medication data
    String data = "";
    for (String header in MedEvent.header) {
      data += "${toBeginningOfSentenceCase(header)},";
    }
    data += "\n";

    for (MedEvent event in eventList) {
      data += event.toCSV();
    }
    // ----------------------------

    data += "\n\n";
    // Exports mood data
    for (String header in MoodEvent.headers) {
      data += "${toBeginningOfSentenceCase(header)},";
    }
    data += "\n";

    List<String> moodCsv =
        moodsList.map((e) => MoodEvent.fromJson(e).toCSV()).toList();
    for (String e in moodCsv) {
      data += e;
    }
    return data;
  }

  void convertTo(SupportedFormats format, bool doShare) async {
    List<MedEvent> eventList = await summary;
    List<dynamic> moodsList = [];
    if (addMoods) {
      //moodsList = await Utils.fetchMoods();
      moodsList = await DatabaseHandler().selectAll("moods");
    }

    switch (format) {
      case SupportedFormats.json:
        {
          // Mood data
          Map<String, dynamic> json = {"moods": moodsList.toList()};

          // Medication data
          json["meds"] = (eventList.map((e) => e.toJson()).toList());

          String data = jsonEncode(json);
          doShare ? shareData(data, "json") : saveData(data, "json");
          break;
        }

      case SupportedFormats.csv:
        {
          String data = buildCSV(eventList, moodsList);
          doShare ? shareData(data, "csv") : saveData(data, "csv");
          break;
        }
    }
  }

  void showExportDialog(bool doShare) async {
    int? doExport = await showDialog<int>(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                ((__, ___) => ExportDialog(
                  doShare: doShare,
                  changeMoodExport: () {
                    setState(() {
                      addMoods = !addMoods;
                    });
                  },
                )),
          ),
    );

    if (doExport == null) {
      return;
    }

    convertTo(SupportedFormats.values[doExport], doShare);
  }

  void removeEvent(MedEvent diffEvent, MedEvent? previousEvent) async {
    var db = DatabaseHandler();

    // Update current event
    if (previousEvent != null) {
      await db.update(
        "events",
        diffEvent.toDBMap(),
        where: "date = ? AND med_uid = ?",
        whereArgs: [diffEvent.datetime.toIso8601String(), diffEvent.uid],
      );
    } else {
      // Pure delete
      await db.delete("events", "date = ? AND med_uid = ?", [
        diffEvent.datetime.toIso8601String(),
        diffEvent.uid,
      ]);
    }
  }

  Future<List<MedEvent>> createEvents() async {
    var json = await DatabaseHandler().rawQuery(
      "SELECT * FROM events e INNER JOIN meds m on m.uid = e.med_uid",
    );
    setState(() {
      this.json = json;
    });

    return Utils.createEvents(json);
  }

  @override
  void initState() {
    super.initState();

    summary = createEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MedEvent>>(
      future: summary,
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          widget = SummaryCalendar(
            medEvents: snapshot.data ?? [],
            json: json,
            removeEvent: removeEvent,
          );
        } else if (snapshot.hasError) {
          widget = Text('${snapshot.error}');
        } else {
          widget = const CircularProgressIndicator();
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: showGraph,
                child: const Icon(Icons.bar_chart),
              ),
              ElevatedButton(
                onPressed: () => showExportDialog(false),
                child: const Icon(Icons.save),
              ),
              ElevatedButton(
                onPressed: () => showExportDialog(true),
                child: const Icon(Icons.share),
              ),
            ],
          ),
          body: widget,
        );
      },
    );
  }
}
