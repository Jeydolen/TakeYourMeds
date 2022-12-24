import 'package:flutter/material.dart';

ColorScheme colorScheme = const ColorScheme.light(
  primary: Colors.blue,
  secondary: Colors.blue,
  onPrimary: Colors.black,
);

ThemeData theme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
  colorScheme: colorScheme,
);
