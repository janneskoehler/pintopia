import 'package:flutter/material.dart';

ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB81618)),
  );
}
