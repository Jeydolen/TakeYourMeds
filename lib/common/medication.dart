class Medication {
  static final List<String> keys = ["name", "dose", "unit", "notes"];
  final String name;
  final String dose;
  final String unit;
  final String notes;
  final String uid;

  Medication(this.name, this.dose, this.unit, this.notes, this.uid);

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "dose": dose,
      "unit": unit,
      "notes": notes,
      "uid": uid,
    };
  }
}
