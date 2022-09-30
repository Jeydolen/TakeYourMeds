import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  NavigationBar({Key? key, required this.selectedId, required this.onClick})
      : super(key: key);
  int selectedId;
  Function onClick;

  @override
  State<NavigationBar> createState() => NavigationBarState();
}

class NavigationBarState extends State<NavigationBar> {
  void nextPage(int index) {
    if (index == widget.selectedId) {
      return;
    }

    setState(() {
      widget.selectedId = index;
    });

    widget.onClick();
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
      currentIndex: widget.selectedId,
      onTap: (int index) => nextPage(index),
    );
  }
}
