import 'package:flutter/material.dart';

ColorScheme colorScheme = const ColorScheme.dark(
  primary: Colors.blue,
  secondary: Colors.blue,
  onPrimary: Colors.white,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
  colorScheme: colorScheme,
);
