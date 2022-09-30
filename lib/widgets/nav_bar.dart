import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  NavigationBar({Key? key, required this.onClick}) : super(key: key);
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.preview),
          label: 'Summary',
        ),
      ],
      currentIndex: currIndex,
      onTap: (int index) => nextPage(index),
    );
  }
}
