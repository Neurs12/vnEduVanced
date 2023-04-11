import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NoInternet extends StatefulWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  bool retrying = false;

  Future<bool> checkInternet() async {
    try {
      await http.get(Uri.parse("https://google.com"));
    } catch (_) {
      return false;
    }
    return true;
  }

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
                      if (await checkInternet()) {
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      }
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
