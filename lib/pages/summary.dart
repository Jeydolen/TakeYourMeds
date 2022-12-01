import 'dart:io';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/common/mood_event.dart';
import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/widgets/summary_calendar.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SummaryPageState();
}

class SummaryPageState extends State<SummaryPage> {
  late Future<List<MedEvent>> summary;
  late List<dynamic> json;

  void exportDataToString(String data, String format) async {
    String now = DateTime.now().toString();
    Directory? pDir = await getExternalStorageDirectory();
    if (pDir == null) {
      return;
    }

    String fullPath = "${pDir.path}/${now}_summary.$format";
    FileHandler.saveToPath(fullPath, data);

    final snackBar =
        SnackBar(content: const Text("file_saved").tr(args: [fullPath]));
    showSnack(snackBar);
  }

  void showSnack(SnackBar snack) {
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  void shareData(String data, String format) async {
    String now = DateTime.now().toString();
    Directory? pDir = await getExternalStorageDirectory();
    if (pDir == null) {
      return;
    }

    String fullPath = "${pDir.path}/${now}_summary.$format";
    File file = File(fullPath);
    file.writeAsString(data);
    Share.shareFiles(
      [fullPath],
      subject: "My summary export",
      text: "This is the text for summary export",
    );
  }

  void exportData(SupportedFormats formats, bool doShare) async {
    List<MedEvent> eventList = await summary;
    List<dynamic> moodsList = await Utils.fetchMoods();

    switch (formats) {
      case SupportedFormats.json:
        {
          // Mood data
          List<dynamic> json = moodsList.toList();

          // Medication data
          json.addAll(eventList.map((e) => e.toJson()).toList());

          String data = jsonEncode(json);
          if (!doShare) {
            exportDataToString(data, "json");
          } else {
            shareData(data, "json");
          }
          return;
        }

      case SupportedFormats.csv:
        {
          // Exports medication data
          String data = "";
          for (var e in MedEvent.header) {
            data += "$e,";
          }
          data += "\n";

          for (var e in eventList) {
            data += e.toCSV();
          }
          // ----------------------------

          data += "\n\n";
          // Exports mood data
          for (var e in MoodEvent.header) {
            data += "$e,";
          }
          data += "\n";

          List<String> moodCsv =
              moodsList.map((e) => MoodEvent.fromJson(e).toCSV()).toList();
          for (var e in moodCsv) {
            data += e;
          }
          // ----------------------------

          if (!doShare) {
            exportDataToString(data, "csv");
          } else {
            shareData(data, "csv");
          }
          return;
        }

      default:
        break;
    }
  }

  void showExportDialog(bool doShare) async {
    AlertDialog dialog = AlertDialog(
      title: const Text("export_summary").tr(),
      content: const Text("select_format")
          .tr(args: [doShare ? "share".tr() : "export".tr()]),
      actions: <Widget>[
        TextButton(
          child: const Text("cancel").tr(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('JSON'),
          onPressed: () => Navigator.of(context).pop(1),
        ),
        ElevatedButton(
          child: const Text('CSV'),
          onPressed: () => Navigator.of(context).pop(2),
        ),
      ],
    );

    int? doExport = await showDialog<int>(
      context: context,
      builder: (BuildContext context) => dialog,
    );

    switch (doExport) {
      case 1:
        return exportData(SupportedFormats.json, doShare);
      case 2:
        return exportData(SupportedFormats.csv, doShare);
      default:
        return;
    }
  }

  void removeEvent(MedEvent? diffEvent) async {
    // Construct json from events
    // In summary_calendar when medEvents gets modified it gets repercuted here
    List<Map> eventsToJson = [];
    for (MedEvent event in await summary) {
      bool found = eventsToJson.any((obj) => obj["uid"] == event.uid);

      if (!found) {
        Map obj = event.toJson();
        obj.remove("time");
        obj.remove("date");
        obj.remove("iso8601_date");
        obj.remove("quantity");
        obj.remove("reason");
        obj["dates"] = [];
        obj["dates"].add({
          "date": event.datetime.toIso8601String(),
          "quantity": event.quantity,
          "reason": event.reason,
        });
        eventsToJson.add(obj);
      } else {
        Map obj = eventsToJson.firstWhere((obj) => obj["uid"] == event.uid);
        obj["dates"].add({
          "date": event.datetime.toIso8601String(),
          "quantity": event.quantity,
          "reason": event.reason,
        });
      }
    }

    for (Map obj in json) {
      if (!eventsToJson.any((element) => element["uid"] == obj["uid"])) {
        if (diffEvent != null) {
          List<dynamic> dates = obj["dates"];
          String diffTime = diffEvent.datetime.toIso8601String();
          dates.removeWhere((e) => e["date"] == diffTime);
        }
        eventsToJson.add(obj);
      }
    }

    FileHandler.writeContent("meds", jsonEncode(eventsToJson));
  }

  Future<List<MedEvent>> createEvents(Future<List<dynamic>> data) async {
    json = await data;
    return await Utils.createEvents(json);
  }

  @override
  void initState() {
    super.initState();
    summary = createEvents(Utils.fetchMeds());
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
