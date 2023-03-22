enum Day {
  monday("mon", 1),
  tuesday("tue", 2),
  wednesday("wed", 3),
  thursday("thu", 4),
  friday("fri", 5),
  saturday("sat", 6),
  sunday("sun", 7);

  const Day(this.string, this.weekDay);

  static Day? fromString(String s) {
    try {
      return Day.values.firstWhere((day) => day.string == s);
    } on Exception catch (_) {
      return null;
    }
  }

  final int weekDay;
  final String string;
}
