import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/enums/mood.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/medication.dart';
import 'package:take_your_meds/widgets/event_list.dart';

class ExpandedSummaryPage extends StatefulWidget {
  const ExpandedSummaryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExpandedSummaryPageState();
}

class ExpandedSummaryPageState extends State<ExpandedSummaryPage> {
  Widget view = const CircularProgressIndicator();
  List<dynamic> events = [];
  List<MedEvent> medEvents = [];
  Function? showEvt;
  Function? removeEvt;
  Function? getEvtForDay;
  late DateTime day;
  List<dynamic>? moods;

  void gotoDate(DateTime date) {
    // Recreate page with other day
    Navigator.pushReplacementNamed(
      context,
      "/expanded_summary",
      arguments: {
        "day": date,
        "show_event": showEvt,
        "remove_event": removeEvt,
        "get_events_for_day": getEvtForDay,
        "med_events": medEvents
      },
    );
  }

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

  Future<void> getMoods() async {
    var res = await Utils.fetchMoods();

    setState(() {
      moods = res;
    });
  }

  void populateSummary() async {
    if (moods == null) {
      await getMoods();
    }

    Widget body = Center(child: const Text("nothing_show").tr());

    if (mounted) {
      List<Map<String, dynamic>> total = [];
      for (MedEvent event in medEvents) {
        int index = total.indexWhere((element) => element["uid"] == event.uid);
        if (index == -1) {
          Medication eventMed = event.medication;
          Map<String, dynamic> el = {
            "uid": event.uid,
            "name": "${eventMed.name} ${eventMed.dose} ${eventMed.unit}",
            "unit": eventMed.unit,
            "dose": eventMed.dose,
            "quantity": event.quantity,
          };

          total.add(el);
        } else {
          Map<String, dynamic> el = total[index];
          el["quantity"] = el["quantity"] + event.quantity;

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

      List<Widget> moodWidgets = [];
      for (Map<String, dynamic> el in moods!) {
        DateTime moodDate = DateTime.parse(el["date"]);
        Duration timeDiff = moodDate.difference(day);
        // Getting only moods for current day
        if (timeDiff.isNegative || timeDiff > const Duration(days: 1)) {
          continue;
        }
        Mood mood = Mood.fromValue(el["mood_int"]);
        var widget = Container(
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: mood.moodColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr(mood.string)),
                Text(DateFormat.Hm().format(moodDate)),
              ],
            ),
          ),
        );
        moodWidgets.add(widget);
      }

      body = ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: const Text("total").tr()),
          ),
          ...totalWidgets,
          moodWidgets.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: const Text("mood").tr()),
                )
              : const SizedBox(),
          ...moodWidgets,
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

      setState(() {
        view = body;
      });
    }
  }

  DateTime dateAtMidnight(DateTime time) {
    return DateTime(time.year, time.month, time.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic events = ModalRoute.of(context)!.settings.arguments;

    if (events["get_events_for_day"] is Function) {
      getEvtForDay = events["get_events_for_day"];
    }

    if (events["day"] is DateTime) {
      day = dateAtMidnight(events["day"]);
      getMoods();
    }

    medEvents = getEvtForDay!(day);

    if (events["show_event"] is Function) {
      showEvt = events["show_event"];
    }

    if (events["remove_event"] is Function) {
      removeEvt = events["remove_event"];
    }

    // Do not forget to update view
    populateSummary();
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      day = dateAtMidnight(DateTime.now());
    });
  }

  String dateToString(DateTime date) {
    return DateFormat.yMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    String dayOfEvents = dateToString(day);
    DateTime dayBefore = day.subtract(const Duration(days: 1));
    DateTime dayAfter = day.add(const Duration(days: 1));

    // https://stackoverflow.com/questions/55050463/how-to-detect-swipe-in-flutter
    return SizedBox.expand(
      child: GestureDetector(
        onPanUpdate: (details) {
          // Swiping in right direction.
          if (details.delta.dx > 0) {
            gotoDate(dayBefore);
          }

          // Swiping in left direction.
          if (details.delta.dx < 0) {
            gotoDate(dayAfter);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("expanded_summary").tr(args: [dayOfEvents]),
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).canvasColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    gotoDate(dayBefore);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back),
                      Text(dateToString(dayBefore)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    gotoDate(dayAfter);
                  },
                  child: Row(
                    children: [
                      Text(dateToString(dayAfter)),
                      const Icon(Icons.arrow_forward)
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: view,
        ),
      ),
    );
  }
}
