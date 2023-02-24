import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:take_your_meds/common/supported_formats.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/mood_event.dart';
import 'package:take_your_meds/common/file_handler.dart';
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

  void showSnackBar(String path) {
    final snack = SnackBar(content: const Text("file_saved").tr(args: [path]));
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  void saveData(String data, String format) async {
    String now = DateTime.now().toString();
    // We want user to get file easily so putting it in Downloads folder.
    // We are only supporting Android which path is always
    // /storage/emulated/0/Download/

    Directory? pDir = await getExternalStorageDirectory();
    if (pDir == null) {
      return;
    }

    String fullPath = "${pDir.path}/${now}_summary.$format";
    //FileHandler.saveToPath(fullPath, data);
    showSnackBar(fullPath);
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
    Share.shareXFiles(
      [XFile(fullPath)],
      subject: "My summary export",
      text: "This is the text for summary export",
    );
  }

  void convertTo(SupportedFormats formats, bool doShare) async {
    List<MedEvent> eventList = await summary;
    List<dynamic> moodsList = [];
    if (addMoods) {
      moodsList = await Utils.fetchMoods();
    }

    switch (formats) {
      case SupportedFormats.json:
        {
          // Mood data
          List<dynamic> json = moodsList.toList();

          // Medication data
          json.addAll(eventList.map((e) => e.toJson()).toList());

          String data = jsonEncode(json);
          if (!doShare) {
            saveData(data, "json");
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
          for (var e in MoodEvent.headers) {
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
            saveData(data, "csv");
          } else {
            shareData(data, "csv");
          }
          return;
        }

      default:
        break;
    }
  }

  void changeMoodExport() {
    setState(() {
      addMoods = !addMoods;
    });
  }

  void showExportDialog(bool doShare) async {
    int? doExport = await showDialog<int>(
      context: context,
      builder: (BuildContext _) => StatefulBuilder(
        builder: ((context, setState) => ExportDialog(
              doShare: doShare,
              changeMoodExport: changeMoodExport,
            )),
      ),
    );

    if (doExport == null) {
      return;
    }

    convertTo(SupportedFormats.values[doExport], doShare);
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
