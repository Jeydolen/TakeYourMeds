import 'package:flutter/material.dart';

ColorScheme colorScheme = ColorScheme.dark(
  primary: Colors.blue[200]!,
  secondary: Colors.blue[200]!,
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
