import 'package:flutter/material.dart';

ColorScheme colorScheme = const ColorScheme.light(
  // primary: Colors.blue,
  // secondary: Colors.blue,
  // onPrimary: Colors.white,
);

AppBarTheme appBarTheme = const AppBarTheme();

ThemeData theme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  appBarTheme: appBarTheme,
  colorScheme: colorScheme,
);
