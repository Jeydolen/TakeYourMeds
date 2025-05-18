import 'package:flutter/material.dart';
import 'package:take_your_meds/widgets/last_med_taken.dart';
import 'package:take_your_meds/widgets/clock_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Key key = UniqueKey();

  void addMed() async {
    Navigator.pushNamed(context, '/add_med');
  }

  void rebuild() {
    // Rebuild last med taken
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ClockButton(rebuild), LastMedTaken(key: key)],
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: const BorderSide(color: Colors.grey, width: 1),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(15),
          minimumSize: const Size(100, 60),
        ),
        onPressed: addMed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
