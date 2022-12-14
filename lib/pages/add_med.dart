import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/unit.dart';
import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/medication.dart';
import 'package:take_your_meds/common/file_handler.dart';

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
    List<dynamic> currMeds = await Utils.fetchMeds();

    formData["unit"] = dropdownValue;
    Medication med = Medication(
      formData["name"],
      formData["dose"],
      dropdownValue,
      formData["notes"],
      const Uuid().v4(),
    );
    currMeds.add(med.toJson());

    // ignore: use_build_context_synchronously
    Navigator.pop(context, currMeds);

    FileHandler.writeContent("meds", jsonEncode(currMeds));
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
          decoration: InputDecoration(labelText: field.tr().capitalize()),
          validator: (String? value) => (value == null || value.isEmpty)
              ? "enter_field".tr(args: [field.tr()])
              : null,
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
              .map(
                  (String v) => DropdownMenuItem(value: v, child: Text(v.tr())))
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
        title: const Text("add_med").tr(),
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
                        child: const Text("submit").tr(),
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
