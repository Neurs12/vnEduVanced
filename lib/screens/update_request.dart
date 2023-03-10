import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vneduvanced/utils/check_update.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:vneduvanced/utils/prefs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vneduvanced/screen_manager.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class UpdatePrompt extends StatefulWidget {
  const UpdatePrompt({Key? key}) : super(key: key);

  @override
  State<UpdatePrompt> createState() => _UpdatePromptState();
}

class _UpdatePromptState extends State<UpdatePrompt> {
  bool downloading = false;
  String percent = "0%";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StatefulBuilder(builder: (context, downloader) {
                    return FloatingActionButton.extended(
                        onPressed: downloading
                            ? null
                            : () async {
                                downloading = !downloading;
                                if (!(await Permission.storage.request().isGranted)) {
                                  downloading = !downloading;
                                  return;
                                }
                                await Dio().download(
                                    "https://github.com/Neurs12/vnEduVanced/raw/main/app-release.apk",
                                    "${(await getTemporaryDirectory()).path}/app-release.apk",
                                    onReceiveProgress: (received, total) {
                                  if (total != -1) {
                                    setState(() {
                                      percent = "${(received / total * 100).toStringAsFixed(0)}%";
                                    });
                                  }
                                });
                                OpenFile.open(
                                    "${(await getTemporaryDirectory()).path}/app-release.apk");
                              },
                        icon: const Icon(Icons.downloading),
                        label: Text(downloading ? percent : "C??i ?????t"));
                  })),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton.extended(
                      onPressed: downloading
                          ? null
                          : () async {
                              dynamic route = Screen().landing;

                              if (await checkUser()) {
                                route = Screen().scores;
                              }
                              if (!mounted) return;
                              Navigator.of(context).popUntil((route) => route.isFirst);
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => route,
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                      icon: const Icon(Icons.event_repeat),
                      label: const Text("Nh???c t??i sau"))),
              FloatingActionButton.extended(
                  onPressed: downloading
                      ? null
                      : () => showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("B??? qua c???p nh???t"),
                                content: const Text("B???n c?? mu???n b??? qua b???n c???p nh???t n??y kh??ng?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("Quay l???i"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("Ok"),
                                    onPressed: () {
                                      setSkipVersion(lastestRelease).then((_) async {
                                        dynamic route = Screen().landing;

                                        if (await checkUser()) {
                                          route = Screen().scores;
                                        }
                                        if (!mounted) return;
                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1, animation2) => route,
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration: Duration.zero,
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text("B??? qua b???n n??y")),
            ]),
        appBar: AppBar(title: Text("C???p nh???t phi??n b???n $lastestRelease")),
        body: Markdown(data: changelog));
  }
}
