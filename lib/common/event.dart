import 'med_event.dart';
import 'medication.dart';

abstract class Event {
  // Headers for csv export
  //static final List<String> headers = [];
  static final List headers = [...Medication.keys, ...MedEvent.keys];
  Map<String, dynamic> toJson() {
    return {};
  }

  String toCSV() {
    String csv = "";

    Map json = toJson();
    for (int i = 0; i < json.length; i++) {
      if (json[headers[i]] != null) {
        csv += "${json[headers[i]]},";
      } else {
        csv += ",";
      }
    }
    csv += "\n";

    return csv;
  }
}
