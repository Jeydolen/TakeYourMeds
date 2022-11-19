import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockButton extends StatefulWidget {
  const ClockButton({Key? key}) : super(key: key);

  @override
  State<ClockButton> createState() => _ClockButtonState();
}

// Based on this: https://github.com/NotThatBowser/flutter_clock/blob/master/circle_clock/lib/components/the_clock.dart
class _ClockButtonState extends State<ClockButton> {
  DateTime _now = DateTime.now();
  late Timer _timer;

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        const Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width / 6),
          minimumSize: const Size(100, 60)),
      onPressed: () => Navigator.pushNamed(context, '/took_med'),
      child: Text(DateFormat.Hms().format(_now)),
    );
  }
}
