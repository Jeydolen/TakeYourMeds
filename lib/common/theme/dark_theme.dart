import 'package:flutter/material.dart';

ColorScheme colorScheme = const ColorScheme.dark(
  // primary: Colors.blue,
  // secondary: Colors.blue,
  // onPrimary: Color.fromARGB(255, 219, 219, 219),
  // surface: Colors.grey,
);

AppBarTheme appBarTheme = const AppBarTheme();

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  appBarTheme: appBarTheme,
  colorScheme: colorScheme,
);
