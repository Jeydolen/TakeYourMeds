import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:take_your_meds/common/medication.dart';
import 'package:take_your_meds/common/month.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/widgets/graph_dropdown.dart';

class GraphsPage extends StatefulWidget {
  const GraphsPage({super.key});

  @override
  State<StatefulWidget> createState() => GraphsPageState();
}

class GraphsPageState extends State<GraphsPage> {
  Widget chart = const CircularProgressIndicator();
  Widget legend = const SizedBox();
  Widget dropdowns = const SizedBox();
  late int selectedYear;
  late Month selectedMonth;
  late List<Medication> meds;
  List<MedEvent>? medEvents;
  List<List<MedEvent>>? filteredEvents;

  @override
  void initState() {
    super.initState();

    getMedEvents();
    getMeds();
    buildDropdowns();
  }

  Future<void> getMeds() async {
    List medsJson = await Utils.fetchMeds();
    setState(() {
      meds = medsJson
          .map((e) => Medication(
                e["name"],
                e["dose"],
                e["unit"],
                e["notes"],
                e["uid"],
              ))
          .toList();
    });
  }

  Future<void> getMedEvents() async {
    List<dynamic> jsonMeds = await Utils.fetchMeds();

    setState(() {
      medEvents = Utils.createEvents(jsonMeds);

      // Sorting by date
      medEvents!.sort(((a, b) => a.datetime.compareTo(b.datetime)));
    });
  }

  List<List<MedEvent>> mergeEvents(List<MedEvent> events) {
    if (events.isEmpty) {
      return [];
    }

    Map<int, List?> daysToEventLength = {};
    for (var event in events) {
      int day = event.datetime.day;
      List? days = daysToEventLength[day];

      if (days == null) {
        daysToEventLength[day] = [];
        daysToEventLength[day]!.add(events.indexOf(event));
      } else {
        days.add(events.indexOf(event));
      }
    }

    List<List<MedEvent>> filteredEvents = [];
    for (MapEntry entry in daysToEventLength.entries) {
      List? indexes = entry.value;

      if (indexes == null || indexes.isEmpty) {
        continue;
      }

      List<MedEvent> eventsInDay = [];
      for (int index in indexes) {
        MedEvent event = events[index];

        int i = eventsInDay.indexWhere((el) => el.uid == event.uid);

        if (i == -1) {
          eventsInDay.add(event);
        } else {
          int previousQty = eventsInDay[i].quantity;
          eventsInDay[i] = MedEvent(
            event.medication,
            previousQty + event.quantity,
            event.datetime,
            event.reason,
          );
        }
      }
      filteredEvents.add(eventsInDay);
    }

    return filteredEvents;
  }

  void filterEvents({int? year, Month? month, Medication? med}) {
    if (medEvents == null) {
      return;
    }

    int filterYear = year ??= selectedYear;
    Month filterMonth = month ??= selectedMonth;
    DateTime filteredTime = DateTime(filterYear, filterMonth.integer);

    List<MedEvent> currentMonthEvents = medEvents!
        .where((el) => isSameMonth(el.datetime, filteredTime))
        .toList();

    List<List<MedEvent>> mergedEvents = mergeEvents(currentMonthEvents);

    setState(() {
      filteredEvents = mergedEvents;
    });
    buildChart();
  }

  void updateTime(int year, Month month) {
    setState(() {
      selectedYear = year;
      selectedMonth = month;
    });
  }

  void buildDropdowns() async {
    if (medEvents == null) {
      await getMedEvents();
    }

    DateTime now = DateTime.now();
    setState(() {
      dropdowns = GraphDropdown(
        events: medEvents ??= [],
        update: filterEvents,
        updateTime: updateTime,
      );

      selectedMonth = Month.values[now.month - 1];
      selectedYear = now.year;
    });

    filterEvents();
    return;
  }

  Map<String, Color> buildLegend() {
    Map<String, Color> meds = {};
    Random random = Random();

    for (MedEvent event in medEvents!) {
      DateTime eventTime = event.datetime;
      Medication eventMed = event.medication;

      // Taking only meds for selected month
      if (eventTime.year == selectedYear &&
          eventTime.month == selectedMonth.integer) {
        if (!meds.containsKey(eventMed.name)) {
          meds[eventMed.name] =
              Color((random.nextInt(0xFFFFFF)).toInt()).withOpacity(1.0);
        }
      }
    }

    List<Widget> legendEls = [];
    for (MapEntry entry in meds.entries) {
      legendEls.add(
        TextButton(
          onPressed: () {},
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 4),
              Text(entry.key),
              const SizedBox(width: 10),
            ],
          ),
        ),
      );
    }

    setState(() {
      legend = Row(children: legendEls);
    });

    return meds;
  }

  void buildChart() {
    List<List<MedEvent>> events = filteredEvents ??= [];
    if (events.isEmpty) {
      setState(() {
        this.chart = Center(
          child: const Text("nothing_show").tr(),
        );
      });
      return;
    }

    DateFormat dayPrecise = DateFormat.Md();
    List<String> dates = [];
    List<BarChartGroupData> barGroups = [];
    List<BarChartRodData> barRods = [];
    Map<String, Color> meds = buildLegend();

    for (int i = 0; i < events.length; i++) {
      List<MedEvent> eventsInDay = events[i];
      if (eventsInDay.isEmpty) {
        continue;
      }

      dates.add(dayPrecise.format(eventsInDay[0].datetime));
      for (MedEvent event in eventsInDay) {
        barRods.add(
          BarChartRodData(
            toY: event.quantity.toDouble(),
            color: meds[event.medication.name],
          ),
        );
      }

      barGroups.add(BarChartGroupData(x: i, barRods: barRods));
      barRods = [];
    }

    BarChart chart = BarChart(
      BarChartData(
        barGroups: barGroups,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (dates.length - 1 < value.toInt()) {
                  return const SizedBox();
                }
                return Text(dates[value.toInt()]);
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text("quantity").tr(),
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
      ),
    );

    setState(() {
      this.chart = chart;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: legend,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .5,
            child: Padding(
              padding: const EdgeInsets.only(right: 18, top: 40, bottom: 18),
              child: chart,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: dropdowns,
          ),
        ],
      ),
    );
  }
}
