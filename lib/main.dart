import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:take_your_meds/app.dart';
import 'package:take_your_meds/pages/expanded_summary.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:take_your_meds/common/theme.dart';
import 'package:take_your_meds/common/dark_theme.dart';

import 'package:take_your_meds/pages/home.dart';
import 'package:take_your_meds/pages/add_med.dart';
import 'package:take_your_meds/pages/took_med.dart';
import 'package:take_your_meds/pages/add_reminder.dart';
import 'package:take_your_meds/pages/took_med_presentation.dart';

FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flnp.initialize(initializationSettings);
  await EasyLocalization.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Brussels'));
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [Locale('fr'), Locale('en')],
      child: const Main(),
    ),
  );
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<MainState>()!.restartApp();
  }

  @override
  State<StatefulWidget> createState() => MainState();
}

class MainState extends State<Main> {
  static Widget currentPage = const HomePage();
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key,
      title: 'Take your meds',
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: theme,
      darkTheme: darkTheme,
      initialRoute: '/',
      routes: {
        '/': (BuildContext _) => const App(),
        '/add_med': (BuildContext _) => const AddMedPage(),
        '/took_med': (BuildContext _) => const TookMedPage(),
        '/med_presentation': (BuildContext _) =>
            const TookMedPresentationPage(),
        '/add_alarm': (BuildContext _) => const AddReminderPage(),
        '/expanded_summary': (BuildContext _) => const ExpandedSummaryPage(),
      },
    );
  }
}
