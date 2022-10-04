import 'dart:convert';

import 'package:take_your_meds/common/medication.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:take_your_meds/common/file_handler.dart';

const List<String> units = ["mg", "g", "ml", "cl", "l", "drops", "occur."];

class AddMedPage extends StatefulWidget {
  const AddMedPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddMedPageState();
}

class AddMedPageState extends State<AddMedPage> {
  String dropdownValue = units.first;
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
    FileHandler.writeContent("meds", jsonEncode(currMeds));
    Navigator.pop(context, currMeds);
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
                  children: <Widget>[
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(hintText: 'Name'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        formData['name'] = value;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Dose'),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a dosage';
                              }
                              return null;
                            },
                            onSaved: (String? value) {
                              formData['dose'] = value;
                            },
                          ),
                        ),
                        Expanded(
                            child: DropdownButtonFormField(
                          isDense: false,
                          decoration:
                              InputDecoration(contentPadding: EdgeInsets.zero),
                          value: dropdownValue,
                          items: units
                              .map<DropdownMenuItem<String>>((String value) =>
                                  DropdownMenuItem<String>(
                                      value: value, child: Text(value)))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              dropdownValue = value!;
                            });
                          },
                        )),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Notes',
                      ),
                      onSaved: (String? value) {
                        formData['notes'] = value;
                      },
                    ),
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
