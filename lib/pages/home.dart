import 'package:flutter/material.dart' hide NavigationBar;
import 'package:take_your_meds/pages/misc.dart';

import 'package:take_your_meds/pages/summary.dart';
import 'package:take_your_meds/widgets/navigation_bar.dart';
import 'package:take_your_meds/widgets/clock_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int selectedId = 0;
  static final List<Widget> _pages = [
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [ClockButton()],
      ),
    ),
    const SummaryPage(),
    const MiscPage(),
  ];

  void change(int index) {
    setState(() {
      selectedId = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(selectedId),
      bottomNavigationBar: NavigationBar(onClick: change),
      floatingActionButton: selectedId == 0
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () => Navigator.pushNamed(context, '/add_med'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
