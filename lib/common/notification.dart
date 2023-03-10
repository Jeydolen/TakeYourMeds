import 'package:take_your_meds/common/day.dart';

class Notification {
  String title;
  String body;
  dynamic payload;
  DateTime time = DateTime.now();
  List<Day> periodicDays = [];

  Notification(this.title, this.body,
      {DateTime? time, List<Day>? days, this.payload}) {
    if (time != null) {
      this.time = time;
    }

    if (days != null && days.length <= 7) {
      // Filter duplicates
      List<Day> previousDays = [];
      for (Day day in days) {
        if (!previousDays.contains(day)) {
          previousDays.add(day);
        }
      }

      periodicDays = previousDays;
    }
  }
}
