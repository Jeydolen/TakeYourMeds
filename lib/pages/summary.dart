import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/widgets/summary_calendar.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SummaryPageState();
}

class SummaryPageState extends State<SummaryPage> {
  late Future<List<MedEvent>> summary;

  void exportDataToString(String data, String format) async {
    String now = DateTime.now().toString();
    Directory? pDir = await getExternalStorageDirectory();
    if (pDir == null) {
      return;
    }

    String fullPath = "${pDir.path}/${now}_summary.$format";
    FileHandler.saveContentWithFullPath(fullPath, data);

    final snackBar = SnackBar(content: Text("File saved at: $fullPath"));
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
      case SupportedFormats.JSON:
        {
          String data = jsonEncode(eventList.map((e) => e.toJson()).toList());
          if (!doShare)
            exportDataToString(data, "json");
          else
            shareData(data, "json");
          return;
        }

      case SupportedFormats.CSV:
        {
          String data = "";
          MedEvent.header.forEach((e) {
            data += e + ",";
          });
          data += "\n";

          eventList.forEach((e) {
            data += e.toCSV();
          });
          if (!doShare)
            exportDataToString(data, "csv");
          else
            shareData(data, "csv");
          return;
        }

      default:
        break;
    }
  }

  void showExportDialog(bool doShare) async {
    AlertDialog dialog = AlertDialog(
      title: Text('Export Summary'),
      content: Text(
          'Please, select a format to ${doShare ? "share" : "export"} your data otherwise press Cancel.'),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('JSON'),
          onPressed: () {
            Navigator.of(context).pop(1);
          },
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
        return exportData(SupportedFormats.JSON, doShare);
      case 2:
        return exportData(SupportedFormats.CSV, doShare);
      default:
        return;
    }
  }

  Future<List<dynamic>> fetchSummary() async {
    String? jsonString = await FileHandler.readContent("meds");

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }

    return [];
  }

  Future<List<MedEvent>> createEvents(Future<List<dynamic>> summary) async {
    List<MedEvent> events = [];
    for (var element in await summary) {
      List<dynamic>? dates = element["dates"];
      if (dates != null) {
        dates.forEach((dateObj) {
          DateTime date = DateTime.parse(dateObj["date"]);
          events.add(MedEvent.fromJson(element, date));
        });
      }
    }
    return events;
  }

  @override
  void initState() {
    super.initState();
    summary = createEvents(fetchSummary());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MedEvent>>(
      future: summary,
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          widget = SummaryCalendar(medEvents: snapshot.data ?? []);
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
