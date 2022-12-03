import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class TimeButton extends StatefulWidget {
  const TimeButton({super.key, required this.onPressed});

  final Function onPressed;

  @override
  State<StatefulWidget> createState() => TimeButtonState();
}

class TimeButtonState extends State<TimeButton> {
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        TimeOfDay? tod = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(now),
        );

        if (tod != null) {
          DateTime newTime = DateTime(
            now.year,
            now.month,
            now.day,
            tod.hour,
            tod.minute,
          );

          widget.onPressed(newTime);
          setState(() {
            now = newTime;
          });
        }
      },
      child: Text(DateFormat.Hm().format(now)),
    );
  }
}
