import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>?> getAll() async {
  final prefs = await SharedPreferences.getInstance();
  String? phone = prefs.getString("phone");
  String? provinceId = prefs.getString("provinceId");
  String? studentId = prefs.getString("studentId");
  String? password = prefs.getString("password");
  String? year = prefs.getString("year");
  String? name = prefs.getString("name");
  if (phone != null &&
      provinceId != null &&
      studentId != null &&
      password != null &&
      year != null &&
      name != null) {
    return {
      "phone": phone,
      "provinceId": provinceId,
      "studentId": studentId,
      "password": password,
      "year": year,
      "name": name
    };
  }
  return null;
}

Future<bool> saveAll(String phone, String provinceId, String studentId, String password,
    String year, String name) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("phone", phone);
  await prefs.setString("provinceId", provinceId);
  await prefs.setString("studentId", studentId);
  await prefs.setString("password", password);
  await prefs.setString("year", year);
  await prefs.setString("name", name);
  return true;
}

Future<String?> getYearViewer() async {
  final prefs = await SharedPreferences.getInstance();
  String? year = prefs.getString("year");

  return year ?? DateTime.now().year.toString();
}

Future<int?> getSemesterViewer() async {
  final prefs = await SharedPreferences.getInstance();
  int? semester = prefs.getInt("semester");
  return semester ?? 0;
}

Future<bool> saveYearViewer(String year) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("year", year);
  return true;
}

Future<bool> saveSemesterViewer(int semester) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt("semester", semester);
  return true;
}
