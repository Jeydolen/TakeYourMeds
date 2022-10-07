import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/medication.dart';
import 'package:take_your_meds/common/file_handler.dart';

enum Unit {
  mg(string: "mg"),
  g(string: "g"),
  ml(string: "ml"),
  cl(string: "cl"),
  l(string: "l"),
  drops(string: "drops"),
  occur(string: "occur.");

  const Unit({required this.string});
  final String string;

  List<String> toList() {
    return Unit.values.map((e) => e.string).toList();
  }
}

class AddMedPage extends StatefulWidget {
  const AddMedPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddMedPageState();
}

class AddMedPageState extends State<AddMedPage> {
  String dropdownValue = Unit.values.first.string;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  void saveData() async {
    String? meds = await FileHandler.readContent("meds");
    List<dynamic> currMeds = meds != null ? jsonDecode(meds) : [];

    formData["unit"] = dropdownValue;
    Medication med = Medication(
      formData["name"],
      formData["dose"],
      dropdownValue,
      formData["notes"],
      const Uuid().v4(),
    );
    currMeds.add(med.toJson());
    await FileHandler.writeContent("meds", jsonEncode(currMeds));
    // ignore: use_build_context_synchronously
    Navigator.pop(context, currMeds);
  }

  List genFormFields() {
    List formFields = [];
    for (Field f in Field.values) {
      String field = f.string;
      formFields.add(const SizedBox(height: 10));

      Widget formField;
      if (field != "unit") {
        formField = TextFormField(
          initialValue: field == "notes" ? "/" : null,
          keyboardType: f.inputType,
          decoration: InputDecoration(hintText: field.capitalize()),
          validator: (String? value) =>
              (value == null || value.isEmpty) ? 'Please enter a $field' : null,
          inputFormatters: f.inputType == TextInputType.number
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ]
              : null,
          onSaved: (String? value) {
            formData[field] = value;
          },
        );
      } else {
        formField = DropdownButtonFormField(
          isDense: false,
          decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
          value: dropdownValue,
          items: Unit.values
              .map((e) => e.string)
              .map((String v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (String? value) {
            setState(() {
              dropdownValue = value!;
            });
          },
        );
      }
      formFields.add(formField);
    }
    return formFields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add medication"),
      ),
      body: ListView(
        children: [
          Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ...genFormFields(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            saveData();
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
