import 'package:flutter/material.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/medication.dart';

class SummaryPresentationPage extends StatefulWidget {
  SummaryPresentationPage({Key? key, required this.json, required this.event})
      : super(key: key);
  List<dynamic> json;
  MedEvent event;

  @override
  State<StatefulWidget> createState() => SummaryPresentationPageState();
}

class SummaryPresentationPageState extends State<SummaryPresentationPage> {
  late MedEvent event;
  bool edit = false;
  late List<Medication> meds = getAll();
  Widget dropDown = CircularProgressIndicator();

  List<Medication> getAll() => widget.json
      .map(
        (element) => Medication(
          element["name"],
          element["dose"],
          element["unit"],
          element["uid"],
        ),
      )
      .toList();

  void editEvent(String? uid) async {
    if (uid != null && uid != widget.event.uid) {
      setState(() {
        Medication med = meds.firstWhere((element) => element.uid == uid);
        event = MedEvent.fromJson(
          med.toJson(),
          widget.event.quantity,
          widget.event.datetime,
          widget.event.reason,
        );
      });
    }
  }

  void generateDropDown() {
    List<DropdownMenuItem> a = meds.map((element) {
      return DropdownMenuItem(
        child: Text(element.name),
        value: element.uid,
      );
    }).toList();

    setState(() {
      dropDown = a.length == 1
          ? Text("Can't make it editable because no other meds detected")
          : DropdownButtonFormField<dynamic>(
              value: event.uid,
              onChanged: (value) => editEvent(value),
              items: a,
            );
    });
  }

  void save() {
    Navigator.pop(context, event);
  }

  @override
  void initState() {
    super.initState();
    event = widget.event;
    generateDropDown();
  }

  @override
  Widget build(BuildContext context) {
    Icon editIcon = edit ? Icon(Icons.cancel) : Icon(Icons.edit);
    String name = "Name: ${event.name}";
    String dose = "Dosage: ${event.quantity} x ${event.dose} ${event.unit}";
    String time = "Time: ${event.time}";
    String reason = "Reason: ${event.reason!.isEmpty ? "/" : event.reason}";

    return Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
                onPressed: () => setState(() {
                      edit = !edit;
                    }),
                child: editIcon)
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              edit ? dropDown : Text(name),
              const SizedBox(height: 20),
              Text(dose),
              const SizedBox(height: 20),
              Text(time),
              const SizedBox(height: 20),
              Text(reason),
              const SizedBox(height: 20),
              edit
                  ? ElevatedButton(
                      onPressed: save,
                      child: Text("Save changes"),
                    )
                  : SizedBox(),
            ],
          ),
        ));
  }
}