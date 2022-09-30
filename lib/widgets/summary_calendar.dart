import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:take_your_meds/common/med_event.dart';

class SummaryCalendar extends StatefulWidget {
  const SummaryCalendar({Key? key, required this.medEvents}) : super(key: key);
  final List<MedEvent> medEvents;

  @override
  State<StatefulWidget> createState() => SummaryCalendarState();
}

class SummaryCalendarState extends State<SummaryCalendar> {
  late final ValueNotifier<List<MedEvent>> _selectedEvents;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  List<MedEvent> _getEventsForDay(DateTime day) {
    List<MedEvent> eventsForDay = [];
    for (var event in widget.medEvents) {
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

  @override
  void initState() {
    super.initState();

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
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    onTap: () => print(' ${value[index]}'),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${value[index].name}'),
                        Text('${value[index].dose} ${value[index].unit}'),
                        Text('${value[index].time}'),
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
