import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/month.dart';
import 'package:take_your_meds/common/utils.dart';

class GraphDropdown extends StatefulWidget {
  const GraphDropdown({
    super.key,
    required this.events,
    required this.update,
    required this.updateTime,
  });

  final List<MedEvent> events;
  final Function update;
  final Function updateTime;

  @override
  State<StatefulWidget> createState() => GraphDropdownState();
}

class GraphDropdownState extends State<GraphDropdown> {
  late int selectedYear;
  late Month selectedMonth;
  late List<DropdownMenuItem> yearItems;
  late List<DropdownMenuItem> monthItems;

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() {
    List<MedEvent> medEvents = widget.events;
    if (medEvents.isEmpty) {
      return;
    }

    // medEvents are sorted by date in getMedEvents()
    DateTime firstDate = medEvents[0].datetime;
    int lastYear = medEvents[medEvents.length - 1].datetime.year;

    List<DropdownMenuItem> yearItems = [];
    for (int i = firstDate.year; i <= lastYear; i++) {
      yearItems.add(DropdownMenuItem(
        value: i,
        child: Text(i.toString()),
      ));
    }

    List<DropdownMenuItem> monthItems = [];
    for (Month month in Month.values) {
      monthItems.add(DropdownMenuItem(
        value: month,
        child: Text(month.string.tr().capitalize()),
      ));
    }

    DateTime now = DateTime.now();

    setState(() {
      selectedYear = now.year;
      selectedMonth = Month.values[now.month - 1];
      this.yearItems = yearItems;
      this.monthItems = monthItems;
    });
  }

  void changeMonth(dynamic month) {
    setState(() {
      selectedMonth = month;
    });

    widget.updateTime(selectedYear, selectedMonth);
    widget.update(month: month);
  }

  void changeYear(dynamic year) {
    setState(() {
      selectedYear = year;
    });

    widget.updateTime(selectedYear, selectedMonth);
    widget.update(year: year);
  }

  @override
  Widget build(BuildContext context) {
    return widget.events.isEmpty
        ? const SizedBox()
        : Column(
            children: [
              Row(
                children: [
                  Text("${"year".tr()}:"),
                  const SizedBox(width: 20),
                  DropdownButton(
                    items: yearItems,
                    value: selectedYear,
                    onChanged: changeYear,
                  ),
                ],
              ),
              Row(
                children: [
                  Text("${"month".tr()}:"),
                  const SizedBox(width: 20),
                  DropdownButton(
                    items: monthItems,
                    value: selectedMonth,
                    onChanged: changeMonth,
                  ),
                ],
              ),
            ],
          );
  }
}
