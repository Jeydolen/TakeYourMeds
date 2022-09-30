import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:take_your_meds/common/utils.dart';

import 'package:take_your_meds/pages/home.dart';
import 'package:take_your_meds/widgets/nav_bar.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/widgets/summary_calendar.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SummaryPageState();
}

class SummaryPageState extends State<SummaryPage> {
  late Future<List<dynamic>> summary;

  void exportData(String data, String format) async {
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

  void exportDataAsJson() async {
    exportData(jsonEncode(await summary), "json");
  }

  void exportDataAsCSV() async {
    // TODO: Implements recursive CSV converter
    //print(Utils.JSON2CSV(await summary));

    List<dynamic> data = await summary;

    String CSV = "Dates,Name,Dose,Unit,Quantity,Reason\n";

    for (var element in data) {
      String line = "";
      if (element["dates"] == null) {
        // Means there is no dates available for this medication
        line = ",${element["name"]},${element["dose"]},${element["unit"]},";
      }

      element["dates"].forEach((dateObj) {
        line +=
            "${dateObj["date"]},${element["name"]},${element["dose"]},${element["unit"]},${dateObj["quantity"]}";

        if (dateObj["reason"] != null) {
          line += ",${dateObj["reason"]}";
        }

        line += "\n";
      });

      CSV += line + "\n";
    }

    exportData(CSV, "csv");
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

    int? doRemove = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );

    switch (doRemove) {
      case 1:
        return exportDataAsJson();
      case 2:
        return exportDataAsCSV();
      default:
        return;
    }
  }

  void gotoHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const HomePage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<List<dynamic>> fetchSummary() async {
    String? jsonString = await FileHandler.readContent("meds");

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }

    return [];
  }

  @override
  void initState() {
    super.initState();
    summary = fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: summary,
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          widget = SummaryCalendar(json: snapshot.data ?? []);
          //widget = Text('${snapshot.data}');
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
          bottomNavigationBar: NavigationBar(selectedId: 1, onClick: gotoHome),
        );
      },
    );
  }
}
