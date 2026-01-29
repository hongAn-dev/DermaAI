# DermaAI - Ứng dụng Chẩn đoán & Tư vấn Da liễu AI

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)

DermaAI là ứng dụng đa nền tảng (Mobile & Web) thông minh giúp người dùng phân tích các vấn đề về da thông qua hình ảnh sử dụng trí tuệ nhân tạo (AI), đồng thời kết nối trực tiếp với các bác sĩ da liễu để được tư vấn và khám chữa bệnh từ xa.

---

## 📸 Demo & Giao diện (Screenshots)

### 📱 Giao diện Mobile (Android/iOS)
| Màn hình Chụp/Scan | Kết quả Phân tích AI | Chat & Video Call | Danh sách Bác sĩ |
|:------------------:|:--------------------:|:-----------------:|:----------------:|
| <img src="LINK_ANH_SCAN_CUA_BAN" width="200"> | <img src="LINK_ANH_KET_QUA_CUA_BAN" width="200"> | <img src="LINK_ANH_CHAT_CUA_BAN" width="200"> | <img src="LINK_ANH_BAC_SI_CUA_BAN" width="200"> |

### 💻 Giao diện Web (Dashboard)
<div align="center">
  <img src="LINK_ANH_WEB_TONG_QUAN_CUA_BAN" width="100%" alt="Web Dashboard">
</div>

---

## 🌟 Tính năng Nổi bật

### 1. 🤖 Phân tích Da bằng AI (AI Skin Analysis)
* **Chụp & Tải ảnh:** Hỗ trợ chụp ảnh trực tiếp hoặc tải lên từ thư viện.
* **Chẩn đoán thông minh:** Sử dụng mô hình **MobileNetV2** (được huấn luyện trên tập dữ liệu HAM10000) để nhận diện 7 loại bệnh da liễu phổ biến.
* **Kết quả chi tiết:** Hiển thị tên bệnh, độ tin cậy (%) và mức độ nguy hiểm.

### 2. 👨‍⚕️ Tư vấn Bác sĩ (Doctor Consultation)
* **Danh sách Bác sĩ:** Hiển thị danh sách bác sĩ với thông tin chuyên khoa, kinh nghiệm.
* **Tìm kiếm & Lọc:** Tìm kiếm bác sĩ theo **tên** hoặc **chuyên khoa**.
* **Hồ sơ chi tiết:** Xem thông tin chi tiết của từng bác sĩ.

### 3. 💬 Trò chuyện & Video Call (Chat & Call)
* **Chat Realtime:** Nhắn tin thời gian thực với bác sĩ qua Firebase Realtime Database.
    * Gửi tin nhắn văn bản, **hình ảnh** và **tệp tin** (PDF, Doc).
    * **Sửa & Xóa** tin nhắn.
* **Video Call:** Tích hợp **ZegoCloud** cho phép gọi video chất lượng cao, ổn định ngay trong ứng dụng.

### 4. 📝 Quản lý Lịch sử (History Management)
* **Lưu trữ tự động:** Tự động lưu lại kết quả các lần quét da.
* **Tìm kiếm & Lọc:** Tìm kiếm lịch sử theo tên bệnh hoặc ngày tháng.

---

## 🛠️ Công nghệ Sử dụng

| Thành phần | Công nghệ | Mô tả chi tiết |
| :--- | :--- | :--- |
| **Frontend** | **Flutter (Dart)** | Single-codebase chạy trên Android, iOS và Web. |
| **Backend AI** | **Python (FastAPI)** | API Server xử lý ảnh, chạy model MobileNetV2. |
| **Database** | **Firebase Firestore** | Lưu trữ NoSQL cho Users, Doctors, History. |
| **Realtime** | **Firebase Realtime DB** | Xử lý tin nhắn chat độ trễ thấp. |
| **Authentication** | **Firebase Auth** | Đăng nhập Google, Email/Password. |
| **Video Call** | **ZegoCloud SDK** | Dịch vụ Streaming Video/Audio. |

---

## 🚀 Hướng dẫn Cài đặt & Chạy Dự án

### Yêu cầu Tiên quyết
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Python 3.8+](https://www.python.org/downloads/)
* Tài khoản Firebase & ZegoCloud (đã cấu hình trong code).

### Bước 1: Cài đặt Dependencies Frontend
Tại thư mục gốc của dự án:
```bash
flutter pub get
