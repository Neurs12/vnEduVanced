import 'package:flutter/material.dart';
import 'utils/launch_navigator.dart';
import 'utils/check_update.dart';
import 'utils/prefs.dart';

ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
ValueNotifier<MaterialColor> colorTheme = ValueNotifier<MaterialColor>(Colors.pink);
ValueNotifier<String> updateStatus = ValueNotifier<String>("checking");

List<MaterialColor> colorsList = [
  Colors.pink,
  Colors.brown,
  Colors.deepPurple,
  Colors.green,
  Colors.indigo,
  Colors.lightGreen,
  Colors.lime,
  Colors.orange,
  Colors.teal
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  checkUpdate().then((val) => updateStatus.value = !val ? "up-to-date" : "update-available");
  themeMode.value = await getIsDark() ? ThemeMode.dark : ThemeMode.light;
  colorTheme.value = colorsList[await getColor()];
  var route = await navigate();
  runApp(AppContainer(route: route));
}

class AppContainer extends StatelessWidget {
  final Widget route;
  const AppContainer({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: Listenable.merge([themeMode, colorTheme]),
        builder: (context, child) {
          return MaterialApp(
              theme: ThemeData(
                  brightness: Brightness.light,
                  colorSchemeSeed: colorTheme.value,
                  useMaterial3: true),
              darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  colorSchemeSeed: colorTheme.value,
                  useMaterial3: true),
              themeMode: themeMode.value,
              home: route);
        });
  }
}
