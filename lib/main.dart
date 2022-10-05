import 'package:flutter/material.dart';
import 'package:take_your_meds/pages/home.dart';
import 'package:take_your_meds/pages/summary.dart';
import 'package:take_your_meds/pages/add_med.dart';
import 'package:take_your_meds/pages/took_med.dart';
import 'package:take_your_meds/pages/took_med_presentation.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  static Widget currentPage = const HomePage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take your meds',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const HomePage(),
        '/summary': (BuildContext context) => const SummaryPage(),
        '/add_med': (BuildContext context) => const AddMedPage(),
        '/took_med': (BuildContext context) => const TookMedPage(),
        '/med_presentation': (BuildContext context) =>
            const TookMedPresentationPage(),
      },
    );
  }
}
