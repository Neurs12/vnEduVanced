import 'package:http/http.dart';
import 'dart:convert';

String cookies = "";

String uniDecode(String input) {
  return input.replaceAllMapped(RegExp(r'\\u([0-9A-Fa-f]{4})'), (Match unicodeMatch) {
    final int hexCode = int.parse(unicodeMatch.group(1)!, radix: 16);
    final unicode = String.fromCharCode(hexCode);
    return unicode;
  });
}

Future<List<dynamic>> searchStudent(String provinceId, String phone) async {
  var as = await get(Uri.parse(
      "https://hocbadientu.vnedu.vn/sllservices/index.php?call=solienlac.search&search=$phone&tinh_id=$provinceId"));

  cookies = "";
  List<String> rawCookies = as.headers["set-cookie"]!.split(" path=/,");
  cookies += rawCookies[0];
  cookies += rawCookies[1].replaceAll("; path=/; Httponly; Secure", "");
  return jsonDecode(uniDecode(as.body));
}

Future<bool> checkPassword(
    String studentId, String provinceId, String password, String year) async {
  return jsonDecode((await get(
          Uri.parse(
              "https://hocbadientu.vnedu.vn/sllservices/index.php?call=solienlac.checkSll&mahocsinh=$studentId&tinh_id=$provinceId&password=$password&namhoc=$year"),
          headers: {"Cookie": cookies}))
      .body)["success"];
}

Future<Map<dynamic, dynamic>> receiveStudentScores(
    String studentId, String year, String provinceId) async {
  var idk = jsonDecode(uniDecode((await get(
          Uri.parse(
              "https://hocbadientu.vnedu.vn/sllservices/index.php?call=solienlac.getSodiem&mahocsinh=$studentId&namhoc=$year&tinh_id=$provinceId"),
          headers: {"Cookie": cookies}))
      .body));
  return idk;
}

Future<List<String>> availableYears(String studentId, String provinceId) async {
  return [
    for (dynamic year in jsonDecode((await get(
            Uri.parse(
                "https://hocbadientu.vnedu.vn/sllservices/index.php?call=solienlac.getDSNamhoc&mahocsinh=$studentId&tinh_id=$provinceId"),
            headers: {"Cookie": cookies}))
        .body))
      year["nam_hoc"]
  ];
}

Future<dynamic> fastReceiveStudentScores(
    String phone, String provinceId, String studentId, String password, String year) async {
  await searchStudent(provinceId, phone);

  if ((await checkPassword(studentId, provinceId, password, year))) {
    return receiveStudentScores(studentId, year, provinceId);
  }
  return false;
}

Future<dynamic> onGoingStudentScores(String studentId, String year, String provinceId) async {
  return receiveStudentScores(studentId, year, provinceId);
}
