import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';

enum Field {
  name(string: "name", inputType: TextInputType.text),
  dose(string: "dose", inputType: TextInputType.number),
  unit(string: "unit", inputType: TextInputType.text),
  notes(string: "notes", inputType: TextInputType.text);

  const Field({required this.string, required this.inputType});
  final TextInputType inputType;
  final String string;

  @override
  String toString() => string.tr();
}

class Medication {
  static final List<String> keys = Field.values.map((e) => e.string).toList();

  final String name;
  final int dose;
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
