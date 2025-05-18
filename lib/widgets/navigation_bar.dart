import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key, required this.onClick}) : super(key: key);
  final Function onClick;

  @override
  State<NavigationBar> createState() => NavigationBarState();
}

class NavigationBarState extends State<NavigationBar> {
  int currIndex = 0;

  void nextPage(int index) {
    if (index == currIndex) {
      return;
    }

    setState(() {
      currIndex = index;
    });

    widget.onClick(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: "home".tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.preview),
          label: "summary".tr(),
        ),
        /*
        BottomNavigationBarItem(
          icon: const Icon(Icons.alarm),
          label: "reminders".tr(),
        ),
        */
        BottomNavigationBarItem(
          icon: const Icon(Icons.miscellaneous_services),
          label: "other".tr(),
        ),
      ],
      currentIndex: currIndex,
      onTap: (int index) => nextPage(index),
    );
  }
}
