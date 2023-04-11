import '../utils/reverse_api.dart';
import '../utils/prefs.dart';
import 'package:flutter/material.dart';
import 'searchresult.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

List<String> provinces = [
  "Chọn tỉnh",
  "An Giang",
  "Bà Rịa Vũng Tàu",
  "Bắc Giang",
  "Bắc Kạn",
  "Bạc Liêu",
  "Bắc Ninh",
  "Bến Tre",
  "Bình Dương",
  "Bình Phước",
  "Bình Thuận",
  "Bình Định",
  "Cà Mau",
  "Cần Thơ",
  "Cao Bằng",
  "Đà Nẵng",
  "Đăk Lăk",
  "Đăk Nông",
  "Điện Biên",
  "Đồng Nai",
  "Đồng Tháp",
  "Gia Lai",
  "Hà Giang",
  "Hà Nam",
  "TP. Hà Nội",
  "Hà Tĩnh",
  "Hải Dương",
  "Hải Phòng",
  "Hậu Giang",
  "TP. Hồ Chí Minh",
  "Hoà Bình",
  "Hưng Yên",
  "Khánh Hoà",
  "Kiên Giang",
  "Kon Tum",
  "Lai Châu",
  "Lâm Đồng",
  "Lạng Sơn",
  "Lào Cai",
  "Long An",
  "Nam Định",
  "Nghệ An",
  "Ninh Bình",
  "Ninh Thuận",
  "Phú Thọ",
  "Phú Yên",
  "Quảng Bình",
  "Quảng Nam",
  "Quảng Ngãi",
  "Quảng Ninh",
  "Quảng Trị",
  "Sóc Trăng",
  "Sơn La",
  "Tây Ninh",
  "Thái Bình",
  "Thái Nguyên",
  "Thanh Hóa",
  "Thừa Thiên Huế",
  "Tiền Giang",
  "Trà Vinh",
  "Tuyên Quang",
  "Vĩnh Long",
  "Vĩnh Phúc",
  "Yên Bái"
];

class _LandingScreenState extends State<LandingScreen> {
  ValueNotifier<String> selectedProvince = ValueNotifier<String>("Chọn tỉnh");
  String phoneNumber = "", error = "";
  bool finding = false;

  @override
  void initState() {
    super.initState();
    getAll().then((sn) => sn.runtimeType != Null
        ? selectedProvince.value = provinces[int.parse(sn!["provinceId"]!) - 1]
        : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                "Tra cứu học sinh",
                style: TextStyle(fontSize: 28),
              ),
              const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text("Vui lòng chọn tỉnh và nhập số điện thoại để tra cứu học sinh.",
                      textAlign: TextAlign.center)),
              AnimatedBuilder(
                  animation: selectedProvince,
                  builder: (context, snapshot) {
                    return DropdownButtonFormField<String>(
                      value: selectedProvince.value,
                      menuMaxHeight: 300,
                      onChanged: (String? value) {
                        setState(() => selectedProvince.value = value!);
                      },
                      decoration: const InputDecoration(
                        labelText: "Tỉnh",
                        border: OutlineInputBorder(),
                      ),
                      items: provinces.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    );
                  }),
              const SizedBox(height: 10),
              SizedBox(
                  height: 80,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.phone),
                      labelText: "Số điện thoại",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.always,
                    onChanged: (value) => setState(() => phoneNumber = value),
                    validator: (String? value) {
                      return (value == null || value.length <= 9)
                          ? "Vui lòng nhập số điện thoại"
                          : null;
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                      onPressed: selectedProvince.value != "Chọn tỉnh" &&
                              phoneNumber.length > 9 &&
                              !finding
                          ? () {
                              setState(() => finding = true);
                              searchStudent(provinces.indexOf(selectedProvince.value).toString(),
                                      phoneNumber)
                                  .then((data) {
                                setState(() => finding = false);
                                if (data.isNotEmpty) {
                                  setState(() => error = "");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SearchResultScreen(data: data, phone: phoneNumber)),
                                  );
                                } else {
                                  setState(() => error =
                                      "Không tìm thấy học sinh. Vui lòng kiểm tra số điện thoại và tỉnh của bạn!");
                                }
                              }).catchError((_) {
                                setState(() => {
                                      error =
                                          "Đã xảy ra lỗi, vui lòng kiểm tra lại kết nối mạng của bạn hoặc thử lại sau!",
                                      finding = false
                                    });
                              });
                            }
                          : null,
                      child: SizedBox(
                          width: 100,
                          height: 40,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            finding
                                ? const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                        height: 15, width: 15, child: CircularProgressIndicator()))
                                : Container(),
                            const Text("Tra cứu")
                          ])))),
              Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 140),
                  child: SizedBox(
                    height: 40,
                    child: Text(
                      error,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ))
            ])));
  }
}
