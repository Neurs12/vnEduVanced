import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart';
import 'prefs.dart';
import 'dart:convert';

String changelog = "";
String lastestRelease = "";

Future<bool> checkUpdate() async {
  String currentVersion = (await PackageInfo.fromPlatform()).version;
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
