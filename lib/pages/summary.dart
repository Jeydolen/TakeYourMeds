import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
    Directory? pDir = await getExternalStorageDirectory();
    if (pDir == null) {
      return;
    }

    String now = DateTime.now().toString();
    String fullPath = "${pDir.path}/${now}_summary.$format";
    FileHandler.saveContentWithFullPath(fullPath, data);

    final snackBar = SnackBar(content: Text("File saved at: $fullPath"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void exportData(SupportedFormats formats) async {
    List<MedEvent> eventList = await summary;

    switch (formats) {
      case SupportedFormats.JSON:
        {
          String data = jsonEncode(eventList.map((e) => e.toJson()).toList());
          exportDataToString(data, "json");
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
          exportDataToString(data, "csv");
          return;
        }

      default:
        break;
    }
  }

  void showExportDialog() async {
    AlertDialog dialog = AlertDialog(
      title: Text('Do you really want to remove: ?'),
      content: const Text(
          'If you really want to delete this medication, press Delete otherwise press Cancel.'),
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
          onPressed: () {
            Navigator.of(context).pop(2);
          },
        ),
      ],
    );

    int? doExport = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );

    switch (doExport) {
      case 1:
        return exportData(SupportedFormats.JSON);
      case 2:
        return exportData(SupportedFormats.CSV);
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
                onPressed: showExportDialog,
                child: const Icon(Icons.save),
              ),
            ],
          ),
          body: widget,
        );
      },
    );
  }
}
