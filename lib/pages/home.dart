import 'package:flutter/material.dart';
import 'package:take_your_meds/widgets/clock_button.dart';
import 'package:take_your_meds/pages/summary.dart';

import '../widgets/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void addMed() {
    Navigator.pushNamed(context, '/add_med');
  }

  void gotoSummary() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => SummaryPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            ClockButton(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedId: 0,
        onClick: gotoSummary,
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(15),
        ),
        onPressed: addMed,
        child: Icon(Icons.add),
      ),
    );
  }
}
