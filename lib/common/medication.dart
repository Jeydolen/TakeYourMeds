class Medication {
  static final List<String> keys = ["name", "dose", "unit"];
  final String name;
  final String dose;
  final String unit;
  final String uid;

  Medication(this.name, this.dose, this.unit, this.uid);

  Map<String, dynamic> toJson() {
    return {"name": name, "dose": dose, "unit": unit, "uid": uid};
  }
}
