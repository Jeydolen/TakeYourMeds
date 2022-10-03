import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/pages/summary_presentation.dart';

import '../main.dart';

class SummaryCalendar extends StatefulWidget {
  SummaryCalendar({
    Key? key,
    required this.medEvents,
    required this.json,
    required this.saveData,
  }) : super(key: key);
  List<MedEvent> medEvents;
  final List<dynamic> json;
  Function saveData;

  @override
  State<StatefulWidget> createState() => SummaryCalendarState();
}

class SummaryCalendarState extends State<SummaryCalendar> {
  late List<MedEvent> medEvents;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late final ValueNotifier<List<MedEvent>> _selectedEvents;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

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
      medEvents.remove(value);
      medEvents.add(result);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
      widget.saveData(result);
    }
  }

  @override
  void initState() {
    super.initState();
    medEvents = widget.medEvents;
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TableCalendar(
        startingDayOfWeek: StartingDayOfWeek.monday,
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
        eventLoader: (day) {
          return _getEventsForDay(day);
        },
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => showEvent(event),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${event.name}'),
                        Text('${event.quantity}x ${event.dose} ${event.unit}'),
                        Text('${event.time}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ]);
  }
}
