import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/widgets/event_list.dart';

class ExpandedSummaryPage extends StatefulWidget {
  const ExpandedSummaryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExpandedSummaryPageState();
}

class ExpandedSummaryPageState extends State<ExpandedSummaryPage> {
  Widget view = const CircularProgressIndicator();
  List<MedEvent> medEvents = [];
  List<Widget> events = [];
  Function? showEvt;
  Function? removeEvt;
  DateTime day = DateTime.now();

  void showEvent(MedEvent event) async {
    if (showEvt != null) {
      dynamic result = await showEvt!(event);

      if (result != null) {
        medEvents[medEvents.indexOf(event)] = result;
        populateSummary();
      }
    }
  }

  void removeEvent(MedEvent event) async {
    if (removeEvt != null) {
      dynamic result = await removeEvt!(event);

      if (result is bool && result == true) {
        medEvents.remove(event);
        populateSummary();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic events = ModalRoute.of(context)!.settings.arguments;
    if (events["events"] is List<MedEvent>) {
      medEvents = events["events"];
    }

    if (events["day"] is DateTime) {
      day = events["day"];
    }

    if (events["show_event"] is Function) {
      showEvt = events["show_event"];
    }

    if (events["remove_event"] is Function) {
      removeEvt = events["remove_event"];
    }

    // Do not forget to update view
    populateSummary();
  }

  void populateSummary() {
    Widget body = Center(
      child: const Text("nothing_show").tr(),
    );

    if (medEvents.isNotEmpty) {
      List<Map<String, dynamic>> total = [];
      for (MedEvent event in medEvents) {
        int index = total.indexWhere((element) => element["uid"] == event.uid);
        if (index == -1) {
          Map<String, dynamic> el = {
            "uid": event.uid,
            "name": "${event.name} ${event.dose} ${event.unit}",
            "unit": event.unit,
            "dose": int.parse(event.dose),
            "quantity": int.parse(event.quantity)
          };

          total.add(el);
        } else {
          Map<String, dynamic> el = total[index];
          el["quantity"] = el["quantity"] + int.parse(event.quantity);

          total[index] = el;
        }
      }

      List<Widget> totalWidgets = [];
      for (Map<String, dynamic> el in total) {
        var widget = Container(
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: Theme.of(context).focusColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${el["quantity"]}x"),
                Text(el["name"].toString()),
                Text("${el["quantity"] * el["dose"]} ${el["unit"]}")
              ],
            ),
          ),
        );
        totalWidgets.add(widget);
      }

      body = ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: const Text("total").tr()),
          ),
          ...totalWidgets,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: const Text("summary").tr()),
          ),
          EventList(
            medEvents,
            showEvent,
            removeEvent,
            key: UniqueKey(),
          ),
        ],
      );
    }

    setState(() {
      view = body;
    });
  }

  @override
  Widget build(BuildContext context) {
    String dayOfEvents = DateFormat.yMd().format(day);

    return Scaffold(
      appBar: AppBar(
        title: const Text("expanded_summary").tr(args: [dayOfEvents]),
      ),
      body: view,
    );
  }
}
