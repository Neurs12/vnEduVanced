import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vneduvanced/utils/reverse_api.dart';
import 'package:vneduvanced/utils/saved_user.dart';
import 'package:vneduvanced/screen_manager.dart';
import 'package:flutter/material.dart';

class SearchResultScreen extends StatefulWidget {
  final List<dynamic> data;
  final String phone;
  const SearchResultScreen({Key? key, required this.data, required this.phone}) : super(key: key);

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  String password = "";
  bool isWrongPass = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Kết quả tra cứu")),
        body: Stack(children: [
          SingleChildScrollView(
              child: AnimationLimiter(
                  child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: -50,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [for (dynamic info in widget.data) studentCard(info)],
            ),
          ))),
          Positioned(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                              height: 86,
                              child:
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(
                                        "Có thể bỏ trống nếu mật khẩu chính là số điện thoại.")),
                                TextField(
                                    obscureText: !isWrongPass,
                                    decoration: const InputDecoration(
                                      labelText: "Mật khẩu",
                                      border: OutlineInputBorder(gapPadding: 1),
                                    ),
                                    onChanged: (value) => password = value)
                              ]))))))
        ]));
  }

  Widget studentCard(info) {
    return Card(
        child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            onTap: () {
              if (password == "") {
                password = widget.phone;
              }
              checkPassword(info["ma_hoc_sinh"], info["tinh_id"], password, info["nam_hoc"])
                  .then((result) {
                if (result) {
                  saveAll(widget.phone, info["tinh_id"], info["ma_hoc_sinh"], password,
                          info["nam_hoc"], info["full_name"])
                      .then((_) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => Screen().scores));
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      margin: EdgeInsets.only(bottom: 130, left: 20, right: 20),
                      behavior: SnackBarBehavior.floating,
                      content: Text("Sai mật khẩu. Vui lòng lòng kiểm tra lại!",
                          textAlign: TextAlign.center)));
                  setState(() => isWrongPass = true);
                  Future.delayed(const Duration(seconds: 4, milliseconds: 400))
                      .then((_) => setState(() => isWrongPass = false));
                }
              });
            },
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(children: [
                  Row(children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(info["full_name"],
                              style: const TextStyle(fontSize: 20),
                              maxLines: 1,
                              overflow: TextOverflow.fade),
                          Text("${info["ten_lop"]}", maxLines: 1, overflow: TextOverflow.fade),
                          Text(info["ten_truong"], maxLines: 1, overflow: TextOverflow.fade)
                        ])),
                    const Spacer(),
                    const Padding(
                        padding: EdgeInsets.only(right: 30), child: Icon(Icons.arrow_forward))
                  ]),
                ]))));
  }
}
