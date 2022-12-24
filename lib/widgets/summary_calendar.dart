import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/utils.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/widgets/cancel_button.dart';
import 'package:take_your_meds/pages/summary_presentation.dart';

class SummaryCalendar extends StatefulWidget {
  const SummaryCalendar({
    Key? key,
    required this.medEvents,
    required this.json,
    required this.removeEvent,
  }) : super(key: key);
  final List<MedEvent> medEvents;
  final List<dynamic> json;
  final Function removeEvent;

  @override
  State<StatefulWidget> createState() => SummaryCalendarState();
}

class SummaryCalendarState extends State<SummaryCalendar> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Future<List> moods;

  late List<MedEvent> medEvents;
  late final ValueNotifier<List<MedEvent>> _selectedEvents;

  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  List<MedEvent> _getEventsForDay(DateTime day) {
    List<MedEvent> eventsForDay = [];
    for (var event in medEvents) {
      DateTime date = event.datetime;
      if (isSameDay(date, day)) {
        eventsForDay.add(event);
      }
    }
    return eventsForDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void showEvent(MedEvent value) async {
    MedEvent? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SummaryPresentationPage(
          json: widget.json,
          event: value,
        ),
      ),
    );

    if (result != null) {
      // Removing old event from list
      medEvents.remove(value);

      // Add new version of event
      medEvents.add(result);

      // Update
      _selectedEvents.value = _getEventsForDay(_selectedDay!);

      // Saving new list
      widget.removeEvent(result);
    }
  }

  void removeEvent(MedEvent value) async {
    AlertDialog dialog = AlertDialog(
      title: const Text("del_event_title").tr(),
      content: const Text("del_event").tr(args: [
        value.quantity,
        value.dose,
        value.name,
        value.datetime.toString()
      ]),
      actions: [
        const CancelButton(),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("delete").tr(),
        )
      ],
    );

    // Show confirmation dialog
    bool? doRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext _) => dialog,
    );

    if (doRemove == true) {
      // Removing event from list
      medEvents.remove(value);

      // Telling listener to update
      _selectedEvents.value = _getEventsForDay(_selectedDay!);

      // Workaround to rebuild calendar
      setState(() {
        _calendarFormat = _calendarFormat;
      });

      // Saving new list
      widget.removeEvent(value);
    }
  }

  @override
  void initState() {
    super.initState();
    medEvents = widget.medEvents;
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    moods = Utils.fetchMoods();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).canvasColor,
          child: TableCalendar(
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: {
              CalendarFormat.month: "month".tr(),
              CalendarFormat.twoWeeks: "two_weeks".tr(),
              CalendarFormat.week: "week".tr(),
            },
            firstDay: DateTime.utc(2010, 12, 1),
            lastDay: DateTime.utc(2030, 12, 1),
            focusedDay: DateTime.now(),
            currentDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              markersMaxCount: 5,
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(),
              outsideTextStyle: const TextStyle(),
              weekendTextStyle: const TextStyle(),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(),
              weekendStyle: TextStyle(),
            ),
            eventLoader: (day) => _getEventsForDay(day),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<MedEvent>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  MedEvent event = value[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Theme(
                      data: ThemeData(
                        highlightColor: const Color(0xFFFF0000).withOpacity(.5),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: Theme.of(context).backgroundColor,
                        onTap: () => showEvent(event),
                        onLongPress: () => removeEvent(event),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(event.name),
                            Text(
                              '${event.quantity}x ${event.dose} ${event.unit}',
                            ),
                            Text(event.time),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
