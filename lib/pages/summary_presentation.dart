import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/medication.dart';
import 'package:take_your_meds/common/utils.dart';

class SummaryPresentationPage extends StatefulWidget {
  const SummaryPresentationPage({
    Key? key,
    required this.json,
    required this.event,
  }) : super(key: key);
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

  void generateDropDown(List<Medication> medications) {
    List<DropdownMenuItem> a = generateDropdownItems(medications);
    setState(() {
      dropDown = a.length == 1
          ? const Text("one_med_length").tr()
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
    generateDropDown(meds);
  }

  @override
  Widget build(BuildContext context) {
    Icon editIcon = edit ? const Icon(Icons.cancel) : const Icon(Icons.edit);

    final String? rVal = event.reason;

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
              edit ? dropDown : const Text("med_name").tr(args: [event.name]),
              const SizedBox(height: 20),
              const Text("med_dosage_unit").tr(args: [
                event.quantity,
                event.dose,
                event.unit,
              ]),
              const SizedBox(height: 20),
              const Text("med_notes").tr(args: [
                (event.notes.isEmpty) ? "/" : event.notes,
              ]),
              const SizedBox(height: 20),
              const Text("time").tr(args: [event.time]),
              const SizedBox(height: 20),
              const Text("med_reason").tr(args: [
                (rVal == null || rVal.isEmpty) ? "/" : rVal,
              ]),
              const SizedBox(height: 20),
              edit
                  ? ElevatedButton(
                      onPressed: save,
                      child: const Text("save").tr(),
                    )
                  : const SizedBox(),
            ],
          ),
        ));
  }
}
