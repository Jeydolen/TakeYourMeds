enum Month {
  january("january", 1),
  february("february", 2),
  march("march", 3),
  april("april", 4),
  may("may", 5),
  june("june", 6),
  july("july", 7),
  august("august", 8),
  september("september", 9),
  october("october", 10),
  november("november", 11),
  december("december", 12);

  const Month(this.string, this.integer);

  final String string;
  final int integer;
}
