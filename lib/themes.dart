import 'package:flutter/material.dart';

class Themes {
  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan, brightness: Brightness.dark),
    brightness: Brightness.dark,
    useMaterial3: true,
  );

  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
    useMaterial3: true,
  );
}
