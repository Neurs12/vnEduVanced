import 'package:flutter/material.dart';
import 'utils/check_update.dart';
import 'utils/saved_user.dart';
import 'screen_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  dynamic route = Screen().landing;

  if (await checkUser()) {
    route = Screen().scores;
  }

  bool status = false;
  try {
    status = await checkUpdate();
  } catch (_) {
    route = Screen().noInternet;
  }

  if (status) {
    route = Screen().update;
  }

  runApp(MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light, colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
          brightness: Brightness.dark, colorSchemeSeed: Colors.indigo, useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: route));
}
