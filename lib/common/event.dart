import 'med_event.dart';
import 'medication.dart';

abstract class Event {
  // Headers for csv export
  static final List headers = [...Medication.keys, ...MedEvent.keys];
  Map<String, dynamic> toJson() {
    return {};
  }

  String toCSV() {
    String csv = "";

    Map json = toJson();
    for (String header in headers) {
      if (json[header] != null) {
        csv += "${json[header]},";
      } else {
        csv += ",";
      }

      csv += "\n";
    }

    return csv;
  }
}
