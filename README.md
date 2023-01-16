# vnEdu Vanced
Ứng dụng tùy chỉnh, không quảng cáo để xem điểm trên vnEdu dựa theo công văn 22 của bộ giáo dục (Đã thử ở các cột điểm của học sinh THPT)

## 1. Tại sao?
Tiện lợi cho việc xem điểm của học sinh, tất cả các con điểm đều được chuyển sang điểm trung bình, hiển thị theo môn và theo màu xét theo mức độ "nguy hiểm" của con điểm. Ứng dụng dễ dàng tiếp cận hơn so với bản cũ, không quảng cáo, đơn giản và dễ hiểu kèm theo đó là tự động lưu thông tin đăng nhập để không cần phải tra cứu mỗi lần muốn xem điểm. Được phát triển dựa theo hướng dẫn thiết kế của Material You, đem lại trải nghiệm tốt nhất cho người dùng.

## 2. Cài đặt
#### [Tải trực tiếp](https://github.com/Neurs12/vnEduVanced/raw/main/app-release.apk)

Chỉ cài được cho máy chạy Android, iPhone không được hỗ trợ vì không có kinh phí xuất bản ứng dụng lên cửa hàng!

## 3. Cách hoạt động
Code về phần này được cung cấp ở [lib/utils/reverse_api.dart](https://github.com/Neurs12/vnEduVanced/blob/main/lib/utils/reverse_api.dart)
### 1. Tổng quan:
Có 4 API chính cần được lấy từ trang tra cứu của vnEdu:
- API tra cứu qua số điện thoại và tỉnh thành. (API 1)
- API kiểm tra mật khẩu. (API 2)
- API lấy số năm học được cấp trong tài khoản. (API 3)
- API lấy bảng điểm dạng thô. (API 4)

### 2. Các bước xử lí:
Bước 1: Gửi dữ liệu tới API 1
```
GET https://hocbadientu.vnedu.vn/sllservices/index.php?call=solienlac.search&search=<số điện thoại>&tinh_id=<id tỉnh>
```
Trả về:
```json
[
  {
    "ten_lop": "",
    "nam_hoc": "",
    "truong_id": "",
    "ten_truong": "",
    "khoi": "",
    "tinh_id": "",
    "huyen_id": "",
    "cap": "",
    "ten_tinh": "",
    "ten_huyen": "",
    "full_name": "",
    "ma_hoc_sinh": "",
    "lock_sll_net": true,
    "ser": ".43"
  },
  ...
]
```
Ta nhận được danh sách học sinh được đăng kí bằng số điện thoại đó.

Chú ý tới `ma_hoc_sinh` và "nam_hoc", vì ta sẽ sử dụng nó xuyên suốt quá trình sử dụng API.

Bên cạnh đó, khi nhận được dữ liệu, phần headers của phản hồi sẽ có yêu cầu Set-cookie:
```
Set-Cookie: PHPSESSID=b947vh5vrehuisuioergv834hu; path=/
Set-Cookie: BIGipServerAPP_EDU_HBDT=722837258.20480.0000; path=/; Httponly; Secure
```
Ta chỉ cần `PHPSESSID` và `BIGipServerAPP_EDU_HBDT`, hai miền này sẽ giúp ta xác nhận các hoạt động của mình khi sử dụng API, trong ví dụ này thì ta có cookie trả về server:
```json
{
  "PHPSESSID": "b947vh5vrehuisuioergv834hu",
  "BIGipServerAPP_EDU_HBDT": "722837258.20480.0000"
}
```
Bước 2: Yêu cầu người dùng nhập mật khẩu và gửi tới API 2

Sau khi người dùng nhập mật khẩu thì gửi tới server yêu cầu nhập mật khẩu thứ 2:
```
GET https://hocbadientu.vnedu.vn/sllservices/index.php?call=solienlac.checkSll&mahocsinh=<ma_hoc_sinh>&tinh_id=<id tỉnh>&password=<mat_khau>&namhoc=<nam_hoc>
```
Kèm theo cookie đã lưu.

Trả về:
```json
{
  "success": true
}
```
Hoặc:
```json
{
  "success": false
}
```
Phần này sẽ quyết định liệu mật khẩu bạn nhập có đúng hay không. Nếu có, `success` sẽ là true, nếu sai thì là false.

Bước 3: Lấy bảng điểm thô từ API 4

Khi tất cả mọi thứ đã hoàn thành, ta tiến hành yêu cầu bảng điểm từ server:
```
GET https://hocbadientu.vnedu.vn/sllservices/index.php?call=solienlac.getSodiem&mahocsinh=<ma_hoc_sinh>&namhoc=<nam_hoc>&tinh_id=<id tỉnh>
```
Kèm theo cookie đã lưu.

Từ đây, ta đã có dữ liệu của bảng điểm, chỉ cần phân tích và áp dụng vào code là hoàn thành.

Trong API này sẽ trả về đầy đủ thông tin của 1 năm mình đã chọn, trong trường hợp này sẽ là `nam_hoc`.

Bước tùy chọn: Đổi năm

Khi người dùng muốn đổi năm, ta chỉ việc chạy lại bước 2 và 3, chỉ khác là `nam_hoc` theo người dùng chọn, API 3 sẽ cung cấp cho ta số năm.
```
GET https://hocbadientu.vnedu.vn/sllservices/index.php?call=solienlac.getDSNamhoc&mahocsinh=<ma_hoc_sinh>&tinh_id=<id tỉnh>
```
Kèm theo cookie, ta sẽ có dữ liệu trả về ví dụ dạng như thế này:
```json
[
	{
		...
		"nam_hoc": "2022",
		...
	},
	{
		...
		"nam_hoc": "2021",
		...
	},
	{
		...
		"nam_hoc": "2020",
		...
	}
]
```
Ta chỉ việc lấy miền `nam_hoc` từ đó, ta sẽ có thể hiện thị người dùng số năm có sẵn.

### 3. Đặc biệt của vnEdu:
Khi tiếp cận với vnEdu, ta thấy một số điểm đặc biệt:
  - API của vnEdu không có bất kì API nào thuộc dạng POST như các trang đăng nhập ta thường thấy, buộc tất cả yêu cầu tới máy chủ phải là GET, chính vì điều này nên sẽ có một số điểm khó khăn khi cố tìm hiểu cách hoạt động của trang.
  - Các API được liên kết với nhau gói gọn trong 1 session được lưu trữ bên phía server, cách lưu token duy nhất là gửi headers lệnh Set-cookie chứa token session.
