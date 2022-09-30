import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:uuid/uuid.dart';

const List<String> units = ["mg", "g", "ml", "cl", "l", "drops"];

class AddMedPage extends StatefulWidget {
  const AddMedPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddMedPageState();
}

class AddMedPageState extends State<AddMedPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};
  String dropdownValue = units.first;

  void saveData() async {
    String? meds = await FileHandler.readContent("meds");
    List<dynamic> currMeds = meds != null ? jsonDecode(meds) : [];

    formData["unit"] = dropdownValue;
    formData["uid"] = const Uuid().v4();
    currMeds.add(formData);
    FileHandler.writeContent("meds", jsonEncode(currMeds));
    Navigator.pop(context, currMeds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add medication"),
      ),
      body: Column(
        children: [
          Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                      ),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Dose',
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
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
                        DropdownButton(
                          value: dropdownValue,
                          items: units
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              dropdownValue = value!;
                            });
                          },
                        ),
                      ],
                    ),
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
