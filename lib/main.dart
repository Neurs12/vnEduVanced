import 'utils/reverse_api.dart';
import 'package:flutter/material.dart';
import 'utils/saved_user.dart';
import 'screen_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light, colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
          brightness: Brightness.dark, colorSchemeSeed: Colors.indigo, useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const Wait()));
}

class Wait extends StatefulWidget {
  const Wait({super.key});

  @override
  State<Wait> createState() => _WaitState();
}

class _WaitState extends State<Wait> {
  @override
  Widget build(BuildContext context) {
    dynamic route = Screen().landing;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<String, String>? userObj = await getAll();
      if (userObj != null) {
        dynamic out = await fastReceiveStudentScores(userObj["phone"]!, userObj["provinceId"]!,
            userObj["studentId"]!, userObj["password"]!, userObj["year"]!);

        route = Screen().scores(out, userObj["name"], userObj["studentId"]!, userObj["provinceId"]!,
            userObj["password"]!, await getSemesterViewer(), await getYearViewer());
      }
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => route));
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
