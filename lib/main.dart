import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:take_your_meds/common/database.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:take_your_meds/app.dart';

import 'package:take_your_meds/common/theme/theme.dart';
import 'package:take_your_meds/common/theme/dark_theme.dart';

import 'package:take_your_meds/pages/alarm.dart';
import 'package:take_your_meds/pages/add_med.dart';
import 'package:take_your_meds/pages/took_med.dart';
import 'package:take_your_meds/pages/add_reminder.dart';
import 'package:take_your_meds/pages/expanded_summary.dart';
import 'package:take_your_meds/pages/took_med_presentation.dart';

FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

Future onSelectNotification(String? payload) async {
  await Navigator.push(
    Main.navKey.currentState!.context,
    MaterialPageRoute(builder: (_) => Alarm(payload: payload)),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  DatabaseHandler();

  await flnp.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      onSelectNotification(details.payload);
    },
  );
  await EasyLocalization.ensureInitialized();
  tz.initializeTimeZones();

  //String  timezoneId = 'Europe/Brussels';
  final String timezoneId = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timezoneId));

  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [Locale('fr'), Locale('en')],
      child: const Main(),
    ),
  );
}

class Main extends StatelessWidget {
  static final navKey = GlobalKey<NavigatorState>();

  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      key: key,
      title: 'Take your meds',
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: theme,
      darkTheme: darkTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const App(),
        '/add_med': (_) => const AddMedPage(),
        '/took_med': (_) => const TookMedPage(),
        '/med_presentation': (_) => const TookMedPresentationPage(),
        '/add_alarm': (_) => const AddReminderPage(),
        '/expanded_summary': (_) => const ExpandedSummaryPage(),
        '/alarm': (_) => const Alarm(),
      },
    );
  }
}
