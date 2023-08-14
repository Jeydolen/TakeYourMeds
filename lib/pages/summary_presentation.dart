import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:take_your_meds/common/database.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/medication.dart';
import 'package:take_your_meds/common/utils.dart';

class SummaryPresentationPage extends StatefulWidget {
  const SummaryPresentationPage({
    Key? key,
    required this.event,
  }) : super(key: key);
  final MedEvent event;

  @override
  State<StatefulWidget> createState() => SummaryPresentationPageState();
}

class SummaryPresentationPageState extends State<SummaryPresentationPage> {
  late MedEvent event;
  bool edit = false;
  List<Medication>? meds;
  Widget dropDown = const CircularProgressIndicator();

  Future<List<Medication>> getAll() async {
    List meds = await DatabaseHandler().selectAll("meds");

    return meds
        .map(
          (element) => Medication(
            element["name"],
            element["dose"] is String
                ? int.parse(element["dose"])
                : element["dose"],
            element["unit"],
            element["notes"],
            element["uid"],
          ),
        )
        .toList();
  }

  void editEvent(String? uid) async {
    if (uid != null && uid != event.uid) {
      setState(() {
        Medication med = meds!.firstWhere((element) => element.uid == uid);
        event = MedEvent.fromJson(
          med.toJson(),
          event.quantity,
          event.datetime,
          event.reason,
        );
      });
    }
  }

  void generateDropDown() async {
    meds ??= await getAll();

    List<DropdownMenuItem> a = generateDropdownItems(meds ?? []);
    setState(() {
      dropDown = (a.length == 1)
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
    generateDropDown();
  }

  @override
  Widget build(BuildContext context) {
    Icon editIcon = edit ? const Icon(Icons.cancel) : const Icon(Icons.edit);

    final String? rVal = event.reason;
    final Medication eventMed = event.medication;

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
              edit
                  ? dropDown
                  : const Text("med_name").tr(args: [eventMed.name]),
              const SizedBox(height: 20),
              const Text("med_dosage_unit").tr(args: [
                event.quantity.toString(),
                eventMed.dose.toString(),
                eventMed.unit,
              ]),
              const SizedBox(height: 20),
              const Text("med_notes").tr(args: [
                (eventMed.notes.isEmpty) ? "/" : eventMed.notes,
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
