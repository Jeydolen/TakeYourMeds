import 'package:flutter/material.dart';

ColorScheme colorScheme = ColorScheme.light(
  primary: Colors.blue[900]!,
  secondary: Colors.blue[900]!,
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
