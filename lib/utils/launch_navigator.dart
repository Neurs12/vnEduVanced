import 'package:flutter/material.dart';
import 'package:vneduvanced/screen_manager.dart';
import 'check_update.dart';
import 'prefs.dart';

Future<Widget> navigate() async {
  Widget route = Screen().landing;

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

  if (!(await setupStatus())) {
    route = Screen().stylesetup;
  }

  return route;
}
