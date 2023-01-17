import 'package:http/http.dart';
import 'saved_user.dart';
import 'dart:convert';

String currentVersion = "1.0";
String changelog = "";

String lastestRelease = "";

Future<bool> checkUpdate() async {
  dynamic re = jsonDecode((await get(
          Uri.parse("https://raw.githubusercontent.com/Neurs12/vnEduVanced/main/version.json")))
      .body);
  lastestRelease = re["version"];
  if (lastestRelease != currentVersion && await getSkipVersion() != lastestRelease) {
    changelog = re["changelog"]!;
    return true;
  }
  return false;
}
