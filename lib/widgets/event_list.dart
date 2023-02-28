import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/med_event.dart';

enum SortOrder {
  meds,
  timeAscending,
  timeDescending;

  SortOrder next() {
    List<SortOrder> values = SortOrder.values;
    int currentIndex = values.indexOf(this);
    int nextIndex = currentIndex + 1;

    if (nextIndex < values.length) return values.elementAt(nextIndex);

    return values.elementAt(nextIndex % values.length);
  }
}

class EventList extends StatefulWidget {
  const EventList(this.events, this.showEvent, this.removeEvent, {super.key});

  final List<MedEvent> events;
  final Function showEvent;
  final Function removeEvent;

  @override
  State<StatefulWidget> createState() => EventListState();
}

class EventListState extends State<EventList> {
  List<Widget> events = [];
  SortOrder order = SortOrder.meds;

  void showEvent(MedEvent event) {
    widget.showEvent(event);
  }

  void deleteEvent(MedEvent event) {
    widget.removeEvent(event);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    events = populateList(widget.events);
  }

  List<Widget> populateList(List<MedEvent> medEvents) {
    List<Widget> evts = [];
    for (MedEvent event in medEvents) {
      var widget = Container(
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
            onLongPress: () => deleteEvent(event),
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
      evts.add(widget);
    }

    return evts;
  }

  void changeOrder() {
    // Widget.events is final but .sort() changes current array
    List<MedEvent> medEvents = List.from(widget.events);
    SortOrder nextOrder = order.next();

    if (nextOrder == SortOrder.timeAscending) {
      medEvents.sort(((a, b) => a.datetime.compareTo(b.datetime)));
    } else if (nextOrder == SortOrder.timeDescending) {
      medEvents.sort(((b, a) => a.datetime.compareTo(b.datetime)));
    } else {
      medEvents = widget.events;
    }

    setState(() {
      order = nextOrder;
      events = populateList(medEvents);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("ordered_by").tr(args: [order.name.tr()]),
            TextButton(
              onPressed: changeOrder,
              child: const Icon(Icons.view_timeline),
            ),
          ],
        ),
        ...events,
      ],
    );
  }
}
