import 'package:flutter/material.dart';
import '../screen_manager.dart';
import 'prefs.dart';

Future<Widget> navigate() async {
  Widget route = Screen().landing;

  if (await checkUser()) {
    route = Screen().scores;
  }

  if (!(await setupStatus())) {
    route = Screen().stylesetup;
  }

  return route;
}
