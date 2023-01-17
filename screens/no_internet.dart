import 'package:flutter/material.dart';
import 'package:vneduvanced/utils/check_update.dart';
import 'package:vneduvanced/screen_manager.dart';
import 'package:vneduvanced/utils/saved_user.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  bool retrying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.signal_cellular_connected_no_internet_0_bar, size: 60)),
      const Text("Không có kết nối mạng", style: TextStyle(fontSize: 28)),
      const Text("Vui lòng kiểm tra kết nối của bạn rồi thử lại!"),
      Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
              onPressed: retrying
                  ? null
                  : () async {
                      setState(() => retrying = !retrying);
                      dynamic route = Screen().landing;
                      bool status = false;

                      if (await checkUser()) {
                        route = Screen().scores;
                      }
                      try {
                        status = await checkUpdate();
                      } catch (_) {
                        route = Screen().noInternet;
                      }

                      if (status) {
                        route = Screen().update;
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
              child: SizedBox(
                  width: 75,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    retrying
                        ? const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child:
                                SizedBox(height: 15, width: 15, child: CircularProgressIndicator()))
                        : Container(),
                    const Text("Thử lại")
                  ]))))
    ])));
  }
}
