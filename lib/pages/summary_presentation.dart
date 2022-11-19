import 'package:flutter/material.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/medication.dart';

class SummaryPresentationPage extends StatefulWidget {
  const SummaryPresentationPage(
      {Key? key, required this.json, required this.event})
      : super(key: key);
  final List<dynamic> json;
  final MedEvent event;

  @override
  State<StatefulWidget> createState() => SummaryPresentationPageState();
}

class SummaryPresentationPageState extends State<SummaryPresentationPage> {
  late MedEvent event;
  bool edit = false;
  late List<Medication> meds = getAll();
  Widget dropDown = const CircularProgressIndicator();

  List<Medication> getAll() => widget.json
      .map(
        (element) => Medication(
          element["name"],
          element["dose"],
          element["unit"],
          element["notes"],
          element["uid"],
        ),
      )
      .toList();

  void editEvent(String? uid) async {
    if (uid != null && uid != event.uid) {
      setState(() {
        Medication med = meds.firstWhere((element) => element.uid == uid);
        event = MedEvent.fromJson(
          med.toJson(),
          event.quantity,
          event.datetime,
          event.reason,
        );
      });
    }
  }

  void generateDropDown() {
    List<DropdownMenuItem> a = meds
        .map((element) => DropdownMenuItem(
              value: element.uid,
              child: Text(element.name),
            ))
        .toList();

    setState(() {
      dropDown = a.length == 1
          ? const Text("Can't make it editable because no other meds detected")
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
    Icon editIcon = edit ? const Icon(Icons.cancel) : const Icon(Icons.edit);
    String name = "Name: ${event.name}";
    String dose = "Dosage: ${event.quantity} x ${event.dose} ${event.unit}";
    String notes = "Notes: ${(event.notes.isEmpty) ? "/" : event.notes}";
    String time = "Time: ${event.time}";

    final String? rVal = event.reason;
    String reason = "Reason: ${(rVal == null || rVal.isEmpty) ? "/" : rVal}";

    return Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => setState(() {
                edit = !edit;
              }),
              child: editIcon,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              edit ? dropDown : Text(name),
              const SizedBox(height: 20),
              Text(dose),
              const SizedBox(height: 20),
              Text(notes),
              const SizedBox(height: 20),
              Text(time),
              const SizedBox(height: 20),
              Text(reason),
              const SizedBox(height: 20),
              edit
                  ? ElevatedButton(
                      onPressed: save,
                      child: const Text("Save changes"),
                    )
                  : const SizedBox(),
            ],
          ),
        ));
  }
}
