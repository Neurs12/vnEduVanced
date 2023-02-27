import 'package:flutter/material.dart';
import 'utils/launch_navigator.dart';
import 'utils/prefs.dart';

ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
ValueNotifier<MaterialColor> colorTheme = ValueNotifier<MaterialColor>(Colors.pink);

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
  themeMode.value = await getIsDark() ? ThemeMode.dark : ThemeMode.light;
  colorTheme.value = colorsList[await getColor()];
  runApp(AppContainer(route: await navigate()));
}

class AppContainer extends StatelessWidget {
  final dynamic route;
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
