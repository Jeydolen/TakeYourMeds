import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/widgets/summary_calendar.dart';
import 'package:uuid/uuid.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  static Future<List<dynamic>> fetchSummary() async {
    String? jsonString = await FileHandler.readContent("meds");

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }

    return [];
  }

  @override
  State<StatefulWidget> createState() => SummaryPageState();
}

class SummaryPageState extends State<SummaryPage> {
  late Future<List<MedEvent>> summary;
  late List<dynamic> json;

  void updateIds() async {
    for (Map obj in json) {
      if (obj["uid"] == null) {
        obj["uid"] = const Uuid().v4();
      }
    }

    saveData(null);
  }

  void exportDataToString(String data, String format) async {
    String now = DateTime.now().toString();
    Directory? pDir = await getExternalStorageDirectory();
    if (pDir == null) {
      return;
    }

    String fullPath = "${pDir.path}/${now}_summary.$format";
    FileHandler.saveToPath(fullPath, data);

    final snackBar = SnackBar(content: Text("File saved at: $fullPath"));
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

    switch (formats) {
      case SupportedFormats.json:
        {
          String data = jsonEncode(eventList.map((e) => e.toJson()).toList());
          if (!doShare) {
            exportDataToString(data, "json");
          } else {
            shareData(data, "json");
          }
          return;
        }

      case SupportedFormats.csv:
        {
          String data = "";
          for (var e in MedEvent.header) {
            data += e + ",";
          }
          data += "\n";

          for (var e in eventList) {
            data += e.toCSV();
          }
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
      title: const Text('Export Summary'),
      content: Text(
          'Please, select a format to ${doShare ? "share" : "export"} your data otherwise press Cancel.'),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('JSON'),
          onPressed: () => Navigator.of(context).pop(1),
        ),
        TextButton(
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

  void saveData(MedEvent? diffEvent) async {
    // createEvents but other side
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
    List<MedEvent> events = [];
    json = await data;
    for (var element in json) {
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

  @override
  void initState() {
    super.initState();
    summary = createEvents(SummaryPage.fetchSummary()).then((value) {
      updateIds();
      return value;
    });
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
            saveData: saveData,
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
