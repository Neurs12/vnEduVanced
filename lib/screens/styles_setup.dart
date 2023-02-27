import 'package:flutter/material.dart';
import 'package:vneduvanced/utils/launch_navigator.dart';
import 'package:vneduvanced/utils/prefs.dart';
import 'package:vneduvanced/main.dart';

class StyleSetup extends StatefulWidget {
  const StyleSetup({super.key});

  @override
  State<StyleSetup> createState() => _StyleSetupState();
}

class _StyleSetupState extends State<StyleSetup> {
  int selectedColor = 0;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: SafeArea(
              child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Text("Chọn giao diện phù hợp\nvới bạn",
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 24))),
            CardSet(
                child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Chế độ tối", style: TextStyle(fontSize: 18)),
                Text(themeMode.value == ThemeMode.light ? "Tắt" : "Bật",
                    style: TextStyle(
                        color: Colors.grey[themeMode.value == ThemeMode.dark ? 400 : 600]))
              ]),
              const Spacer(),
              Switch(
                  splashRadius: 0,
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Icon(Icons.dark_mode_outlined);
                    }
                    return const Icon(Icons.light_mode_outlined);
                  }),
                  value: themeMode.value == ThemeMode.dark,
                  onChanged: (_) => setState(() => {
                        themeMode.value =
                            themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark
                      }))
            ])),
            CardSet(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Màu ứng dụng", style: TextStyle(fontSize: 18)),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 48,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (int colorNum = 0; colorNum < colorsList.length; colorNum++)
                          Card(
                              child: InkWell(
                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                  onTap: () => setState(() => {
                                        selectedColor = colorNum,
                                        colorTheme.value = colorsList[selectedColor]
                                      }),
                                  child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: colorsList[colorNum], shape: BoxShape.circle),
                                          height: 40,
                                          width: 40,
                                          child: colorTheme.value == colorsList[colorNum]
                                              ? const Icon(Icons.check, color: Colors.white)
                                              : null))))
                      ])))
            ])),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: !isSaving
                        ? () => {
                              setState(() => isSaving = true),
                              setupStatus(status: true).then((_) {
                                getColor(colorNum: selectedColor).then((_) {
                                  getIsDark(isDark: themeMode.value == ThemeMode.dark)
                                      .then((_) async {
                                    Widget route = await navigate();
                                    if (!mounted) return;
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (context) => route));
                                  });
                                });
                              })
                            }
                        : null,
                    child: const Text("Hoàn thành")))
          ]))),
        ),
        onWillPop: () async {
          Widget route = await navigate();
          if (!mounted) return false;
          await setupStatus()
              ? Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) => route))
              : null;
          return false;
        });
  }
}

class CardSet extends StatelessWidget {
  final Widget child;
  const CardSet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: Padding(padding: const EdgeInsets.all(20), child: child));
  }
}
