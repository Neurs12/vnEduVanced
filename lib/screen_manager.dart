import 'screens/landing.dart';
import 'screens/scores.dart';

class Screen {
  var landing = const LandingScreen();
  dynamic scores(userObj, name, studentId, provinceId, password, semester, year) {
    return ScoresScreen(
        userObj: userObj,
        name: name,
        studentId: studentId,
        provinceId: provinceId,
        password: password,
        semester: semester,
        year: year);
  }
}
