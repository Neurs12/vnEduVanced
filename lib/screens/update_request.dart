import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../utils/check_update.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../utils/prefs.dart';
import 'package:path_provider/path_provider.dart';
import '../screen_manager.dart';
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

  CancelToken cToken = CancelToken();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StatefulBuilder(builder: (context, downloader) {
              return FloatingActionButton.extended(
                  heroTag: null,
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
                          }, cancelToken: cToken);
                          OpenFile.open("${(await getTemporaryDirectory()).path}/app-release.apk");
                        },
                  icon: const Icon(Icons.downloading),
                  label: Text(downloading ? percent : "Cài đặt"));
            })),
        appBar: AppBar(title: Text("Cập nhật phiên bản $lastestRelease")),
        body: Markdown(data: changelog));
  }
}
