import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/utils.dart' hide isSameDay;
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
        _focusedDay = selectedDay;
      });

      List<MedEvent> events = _getEventsForDay(selectedDay);
      events.sort(((b, a) => a.datetime.compareTo(b.datetime)));
      _selectedEvents.value = events;
    }
  }

  Future<MedEvent?> showEvent(MedEvent value) async {
    MedEvent? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryPresentationPage(
          json: widget.json,
          event: value,
        ),
      ),
    );

    if (result != null) {
      // Replacing old value with new event
      medEvents[medEvents.indexOf(value)] = result;

      // Update
      _selectedEvents.value = _getEventsForDay(_selectedDay!);

      // Saving new list
      widget.removeEvent(result);
    }

    return result;
  }

  Future<bool?> removeEvent(MedEvent event) async {
    AlertDialog dialog = AlertDialog(
      title: const Text("del_event_title").tr(),
      content: const Text("del_event").tr(args: [
        event.quantity.toString(),
        event.medication.dose,
        event.medication.name,
        DateFormat.yMMMEd().add_Hm().format(event.datetime)
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
      builder: (_) => dialog,
    );

    if (doRemove == true) {
      // Removing event from list
      medEvents.remove(event);

      // Telling listener to update
      _selectedEvents.value = _getEventsForDay(_selectedDay!);

      // Saving new list
      widget.removeEvent(event);
    }

    return doRemove;
  }

  void showSummaryForDay() {
    Navigator.pushNamed(
      context,
      "/expanded_summary",
      arguments: {
        "day": _focusedDay,
        "show_event": showEvent,
        "remove_event": removeEvent,
        "get_events_for_day": _getEventsForDay
      },
    );
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
            focusedDay: _focusedDay,
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
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            onPressed: showSummaryForDay,
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).canvasColor,
            ),
            child: const Text("expand_summary").tr(),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<MedEvent>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              List<Widget> events = [];

              for (var event in value) {
                events.add(Container(
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
                          Text(event.medication.name),
                          Text(
                            '${event.quantity}x ${event.medication.dose} ${event.medication.unit}',
                          ),
                          Text(event.time),
                        ],
                      ),
                    ),
                  ),
                ));
              }

              return ListView(children: events);
            },
          ),
        ),
      ],
    );
  }
}
