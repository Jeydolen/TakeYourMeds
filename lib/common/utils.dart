import 'package:flutter/material.dart';

class Utils {
  static Future<bool?> dialogBuilder(BuildContext context, AlertDialog dialog) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  static String a(List<dynamic> jsonArr, List<String> header) {
    for (var element in jsonArr) {
      String line = "";
      for (String headerName in header) {
        if (element[headerName] == null) {
          line += ",";
        } else if (element[headerName] is List) {
          for (var el in element[headerName]) {
            header.addAll(el.keys as Iterable<String>);
            print(el);
          }
        } else {
          line += "${element[headerName]},";
        }
      }
      /*
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
*/
      // CSV += line + "\n";
    }
    return "";
  }

  static List<String> extractHeader(List jsonArr, List<String> header) {
    List<String> a = List.from(header);
    for (var jsonObj in jsonArr) {
      for (String key in jsonObj.keys) {
        if (!header.contains(key)) {
          print(key);
          if (jsonObj[key] is List) {
            print(jsonObj[key]);
            extractHeader(jsonObj[key], a);
          } else {
            a.add(key);
          }
        }
      }
    }

    return a;
  }

  static String generateFirstLine(List<String> header) {
    String line = "";
    for (String element in header) {
      line += element + ",";
    }
    return line;
  }

  static String JSON2CSV(List<dynamic> jsonArr) {
    List<dynamic> data = jsonArr;
    String CSV = "";

    List<String> header = extractHeader(jsonArr, []);
    a(jsonArr, header);
    print("Header: $header");

    CSV += "\n";
    //CSV +=jsonObj.keys
    //String CSV = "Dates,Name,Dose,Unit,Quantity,Reason\n";

    for (var element in data) {
      String line = "";
      for (String headerName in header) {
        if (element[headerName] == null) {
          line += ",";
        } else if (element[headerName] is List) {
          for (var el in element[headerName]) {
            print(el);
          }
        } else {
          line += "${element[headerName]},";
        }
      }
      /*
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
*/
      CSV += line + "\n";
    }
    return CSV;
    //exportData(CSV, "csv");
  }
}
