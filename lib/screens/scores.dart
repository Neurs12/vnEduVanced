import '../main.dart';
import '../utils/reverse_api.dart';
import '../utils/prefs.dart';
import '../screen_manager.dart';
import 'package:flutter/material.dart';
import 'styles_setup.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  late int selectedSemester;

  late String selectedSemesterAsStr, selectedYear;

  late List<String> availableYearsDisplayer;

  ValueNotifier<double> scoresCount = ValueNotifier<double>(0),
      totalScore = ValueNotifier<double>(0);

  late Map<String, String>? userObj;
  Map<String, dynamic> overall = {};

  late Future<bool> infoDisplayer, dataDisplayer;

  Future<bool> infoBuilder() async {
    userObj = await getAll();
    selectedSemester = (await getSemesterViewer())!;
    selectedSemesterAsStr = selectedSemester == 0 ? "Học kì 1" : "Học kì 2";
    selectedYear = (await getYearViewer())!;
    availableYearsDisplayer = await availableYears(userObj!["studentId"]!, userObj!["provinceId"]!);
    return true;
  }

  Future<bool> dataBuilder() async {
    if (userObj != null) {
      overall = await fastReceiveStudentScores(userObj!["phone"]!, userObj!["provinceId"]!,
          userObj!["studentId"]!, userObj!["password"]!, (await getYearViewer())!);
    }
    return true;
  }

  Future<bool> midBridgeBuild() async {
    if (userObj != null) {
      overall = await onGoingStudentScores(
          userObj!["studentId"]!, (await getYearViewer())!, userObj!["provinceId"]!);
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    infoDisplayer = infoBuilder().then((_) => dataDisplayer = dataBuilder());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const StyleSetup())),
              icon: const Icon(Icons.color_lens_outlined)),
          title: const Text("vnEdu Vanced"),
          actions: [
            AnimatedBuilder(
                animation: updateStatus,
                builder: (context, child) {
                  return Padding(
                      padding: EdgeInsets.only(right: updateStatus.value == "checking" ? 10 : 0),
                      child: updateStatus.value == "checking"
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator())
                          : updateStatus.value == "up-to-date"
                              ? const Icon(Icons.download_done)
                              : IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => Screen().update));
                                  },
                                  icon: const Icon(Icons.downloading)));
                }),
            IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Screen().landing)),
                icon: const Icon(Icons.edit))
          ],
        ),
        body: FutureBuilder(
            future: infoDisplayer,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                    child: Column(children: [
                  Row(children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 10),
                            child: DropdownButtonFormField<String>(
                              value: selectedSemesterAsStr,
                              menuMaxHeight: 300,
                              onChanged: (String? value) {
                                selectedSemesterAsStr = value!;
                                selectedSemester = selectedSemesterAsStr == "Học kì 1" ? 0 : 1;
                                saveSemesterViewer(selectedSemester).then((_) =>
                                    setState(() => {scoresCount.value = 0, totalScore.value = 0}));
                              },
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: ["Học kì 1", "Học kì 2"]
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ))),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 20),
                            child: DropdownButtonFormField<String>(
                              value: selectedYear,
                              menuMaxHeight: 300,
                              onChanged: (String? value) {
                                checkPassword(userObj!["studentId"]!, userObj!["provinceId"]!,
                                        userObj!["password"]!, value!)
                                    .then((_) {
                                  receiveStudentScores(
                                          userObj!["studentId"]!, value, userObj!["provinceId"]!)
                                      .then((Map<dynamic, dynamic> res) {
                                    saveYearViewer(value).then((_) => setState(() => {
                                          scoresCount.value = 0,
                                          totalScore.value = 0,
                                          dataDisplayer = midBridgeBuild()
                                        }));
                                  });
                                });
                              },
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: availableYearsDisplayer
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )))
                  ]),
                  FutureBuilder(
                      future: dataDisplayer,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Center(
                              child: Column(children: [
                            SizedBox(
                                height: 202,
                                child: Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(bottom: 20, top: 10),
                                      child: Text(userObj!["name"]!,
                                          style: const TextStyle(fontSize: 28))),
                                  const Text("Trung bình môn"),
                                  AnimatedBuilder(
                                      animation: Listenable.merge([scoresCount, totalScore]),
                                      builder: (context, child) {
                                        return Text(
                                            (totalScore.value / scoresCount.value)
                                                .toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 32));
                                      })
                                ])),
                            Wrap(
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  for (dynamic subject in overall["diem"][selectedSemester]
                                      ["mon_hoc"])
                                    Card(
                                        child: InkWell(
                                            borderRadius: BorderRadius.circular(12),
                                            onTap: () => showScoresInfo(subject),
                                            child: SizedBox(
                                                height: 100,
                                                width: 175,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12),
                                                  child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(subject["ten_mon_hoc"],
                                                            style: const TextStyle(fontSize: 16),
                                                            textAlign: TextAlign.center,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.fade),
                                                        scoreScan(subject)
                                                      ]),
                                                ))))
                                ])
                          ]));
                        }
                        return const DummyGrayboxLoader(loginLoad: false);
                      })
                ]));
              }
              return const DummyGrayboxLoader(loginLoad: true);
            }));
  }

  Future<void> showScoresInfo(subject) {
    List keys = subject.keys.toList();
    keys.removeAt(0);
    keys.removeLast();

    Map<String, String> out = {"TX": "", "GK": "", "CK": ""};

    for (String score in keys) {
      if (score == "TX" || score == "M" || score == "P") {
        List<String> textScore = [];
        for (dynamic chip in subject[score]) {
          textScore.add(chip["diem"]);
        }
        out["TX"] = textScore.join(" | ");
      }
      if (score == "GK" || score == "V") {
        List<String> textScore = [];
        for (dynamic chip in subject[score]) {
          textScore.add(chip["diem"]);
        }
        out["GK"] = textScore.join(" | ");
      }
      if (score == "CK" || score == "HK") {
        List<String> textScore = [];
        for (dynamic chip in subject[score]) {
          textScore.add(chip["diem"]);
        }
        out["CK"] = textScore.join(" | ");
      }
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(subject["ten_mon_hoc"]),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text("Thường xuyên: ${out["TX"]}"),
                Text("Giữa kì: ${out["GK"]}"),
                Text("Cuối kì: ${out["CK"]}"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget scoreScan(Map<dynamic, dynamic> subject) {
    List keys = subject.keys.toList();
    keys.removeAt(0);
    keys.removeLast();
    try {
      double out = 0;
      int co = 0;

      for (String score in keys) {
        if (score == "TX" || score == "M" || score == "P") {
          co += subject[score].length as int;
          for (dynamic chip in subject[score]) {
            out += double.parse(chip["diem"]);
          }
        }
        if (score == "GK" || score == "V") {
          co += (subject[score].length as int) * 2;
          for (dynamic chip in subject[score]) {
            out += double.parse(chip["diem"]) * 2;
          }
        }
        if (score == "CK" || score == "HK") {
          co += (subject[score].length as int) * 3;
          for (dynamic chip in subject[score]) {
            out += double.parse(chip["diem"]) * 3;
          }
        }
      }
      String re = (out / co).toStringAsFixed(1);
      double numRe = double.parse(re);
      totalScore.value += re == "NaN" ? 0 : numRe;
      scoresCount.value += re == "NaN" ? 0 : 1;

      return Text(re == "NaN" ? "Không có" : re,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: re != "NaN"
                  ? numRe >= 8
                      ? Colors.green
                      : numRe >= 6.5
                          ? Colors.yellow[600]
                          : numRe >= 5
                              ? Colors.orange
                              : Colors.red
                  : Colors.blueGrey),
          textAlign: TextAlign.center);
    } catch (_) {
      bool failed = false;
      for (String score in keys) {
        for (dynamic chip in subject[score]) {
          if (chip["diem"] == "CĐ") {
            failed = true;
            break;
          }
          if (failed) break;
        }
      }
      return Text(!failed ? "Đạt" : "Chưa Đạt",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: !failed ? Colors.green : Colors.red),
          textAlign: TextAlign.center);
    }
  }
}

class DummyGrayboxLoader extends StatelessWidget {
  final bool loginLoad;
  const DummyGrayboxLoader({super.key, required this.loginLoad});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      loginLoad
          ? Row(children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Padding(
                      padding: EdgeInsets.only(left: 20, right: 10),
                      child: GrayBox(height: 65, width: double.infinity, radius: 5))),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Padding(
                      padding: EdgeInsets.only(left: 20, right: 10),
                      child: GrayBox(height: 65, width: double.infinity, radius: 5))),
            ])
          : Container(),
      SizedBox(
          height: 202,
          child: Column(children: const [
            Padding(
                padding: EdgeInsets.only(bottom: 20, top: 10),
                child: GrayBox(height: 40, width: 250)),
            GrayBox(height: 20, width: 120),
            Padding(padding: EdgeInsets.only(top: 8), child: GrayBox(height: 40, width: 70))
          ])),
      Wrap(
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (int i = 0; i < 10; i++)
              Card(
                  child: SizedBox(
                      height: 100,
                      width: 175,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                          GrayBox(height: 20, width: 80),
                          Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: GrayBox(height: 30, width: 70))
                        ]),
                      )))
          ])
    ]));
  }
}

class GrayBox extends StatelessWidget {
  final double height, width;
  final double? radius;
  const GrayBox({super.key, required this.height, required this.width, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Colors.grey[themeMode.value == ThemeMode.dark ? 900 : 300],
            borderRadius: BorderRadius.all(Radius.circular(radius ?? 10000))));
  }
}
