enum Unit {
  occur(string: "occur."),
  drops(string: "drops"),
  mg(string: "mg"),
  ml(string: "ml"),
  cl(string: "cl"),
  g(string: "g"),
  l(string: "l");

  const Unit({required this.string});
  final String string;

  List<String> toList() => Unit.values.map((e) => e.string).toList();
}
