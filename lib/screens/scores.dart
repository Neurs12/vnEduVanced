import 'package:vneduvanced/utils/reverse_api.dart';
import 'package:vneduvanced/utils/saved_user.dart';
import 'package:vneduvanced/screen_manager.dart';
import 'package:flutter/material.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  late int selectedSemester;
  late String selectedSemesterAsStr;

  late String selectedYear;

  late List<String> availableYearsDisplayer;

  late List<Widget> displayer;
  int scoresCount = 0;
  double totalScore = 0;

  late Map<String, String>? userObj;
  late dynamic overall;

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
    displayer = cardBuilder();
    return true;
  }

  late Future<bool> infoDisplayer;
  late Future<bool> dataDisplayer;

  @override
  void initState() {
    super.initState();
    infoDisplayer = infoBuilder().then((_) => dataDisplayer = dataBuilder());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("vnEdu Vanced"),
          actions: [
            IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Screen().landing),
                    ),
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
                        child: DropdownButtonFormField<String>(
                          value: selectedSemesterAsStr,
                          menuMaxHeight: 300,
                          onChanged: (String? value) {
                            setState(() => {
                                  selectedSemesterAsStr = value!,
                                  selectedSemester = selectedSemesterAsStr == "Học kì 1" ? 0 : 1,
                                  saveSemesterViewer(selectedSemester).then((_) =>
                                      {scoresCount = 0, totalScore = 0, displayer = cardBuilder()}),
                                });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: ["Học kì 1", "Học kì 2"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
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
                                setState(() => {
                                      saveYearViewer(value).then((_) => {
                                            scoresCount = 0,
                                            totalScore = 0,
                                            dataDisplayer = dataBuilder()
                                          }),
                                    });
                              });
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items:
                              availableYearsDisplayer.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ))
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
                                  Text((totalScore / scoresCount).toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 32)),
                                ])),
                            Wrap(
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: displayer)
                          ]));
                        }
                        return const Text("Đang lấy dữ liệu...");
                      })
                ]));
              }
              return const Text("Đang đăng nhập...");
            }));
  }

  List<Widget> cardBuilder() {
    return [
      for (dynamic subject in overall["diem"][selectedSemester]["mon_hoc"])
        Card(
            child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showScoresInfo(subject),
                child: SizedBox(
                    height: 100,
                    width: 175,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(subject["ten_mon_hoc"],
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.fade),
                        scoreScan(subject)
                      ]),
                    ))))
    ];
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
      totalScore += re == "NaN" ? 0 : numRe;
      scoresCount += re == "NaN" ? 0 : 1;

      return Text(re == "NaN" ? "Không có" : re,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: re != "NaN"
                  ? numRe >= 8
                      ? Colors.green
                      : numRe >= 6.5
                          ? Colors.yellow
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
