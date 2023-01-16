import 'package:flutter/material.dart';
import 'screen_manager.dart';

void main() async {
  runApp(MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light, colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
          brightness: Brightness.dark, colorSchemeSeed: Colors.indigo, useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Screen().scores()));
}
