# DermaAI - Ứng dụng Chẩn đoán & Tư vấn Da liễu AI

DermaAI là ứng dụng di động thông minh giúp người dùng phân tích các vấn đề về da thông qua hình ảnh sử dụng trí tuệ nhân tạo (AI), đồng thời kết nối trực tiếp với các bác sĩ da liễu để được tư vấn và khám chữa bệnh từ xa.

## 🌟 Tính năng Nổi bật

### 1. 🤖 Phân tích Da bằng AI (AI Skin Analysis)
*   **Chụp & Tải ảnh:** Hỗ trợ chụp ảnh trực tiếp hoặc tải lên từ thư viện.
*   **Chẩn đoán thông minh:** Sử dụng mô hình **MobileNetV2** (được huấn luyện trên tập dữ liệu HAM10000) để nhận diện 7 loại bệnh da liễu phổ biến.
*   **Kết quả chi tiết:** Hiển thị tên bệnh, độ tin cậy (%) và mức độ nguy hiểm.

### 2. 👨‍⚕️ Tư vấn Bác sĩ (Doctor Consultation)
*   **Danh sách Bác sĩ:** Hiển thị danh sách bác sĩ với thông tin chuyên khoa, kinh nghiệm.
*   **Tìm kiếm & Lọc:** Tìm kiếm bác sĩ theo **tên** hoặc **chuyên khoa**.
*   **Hồ sơ chi tiết:** Xem thông tin chi tiết của từng bác sĩ.

### 3. 💬 Trò chuyện & Video Call (Chat & Call)
*   **Chat Realtime:** Nhắn tin thời gian thực với bác sĩ.
    *   Gửi tin nhắn văn bản.
    *   Gửi **hình ảnh** và **tệp tin** (PDF, Doc, v.v.).
    *   **Sửa & Xóa** tin nhắn (chỉ cho phép sửa tin nhắn văn bản).
    *   **Vuốt để xóa** cuộc trò chuyện.
    *   Tìm kiếm nội dung tin nhắn trong danh sách chat.
*   **Video Call:** Tích hợp **ZegoCloud** cho phép gọi video chất lượng cao, ổn định ngay trong ứng dụng.

### 4. 📝 Quản lý Lịch sử (History Management)
*   **Lưu trữ tự động:** Tự động lưu lại kết quả các lần quét da.
*   **Tìm kiếm:** Tìm kiếm lịch sử theo tên bệnh.
*   **Lọc theo Ngày:** Xem lại lịch sử theo ngày cụ thể.
*   **Xóa lịch sử:** Cho phép xóa từng bản ghi không cần thiết.

## 🛠️ Công nghệ Sử dụng

*   **Frontend:** [Flutter](https://flutter.dev/) (Dart) - Ứng dụng đa nền tảng (Mobile/Web).
*   **Backend (AI):** [Python FastAPI](https://fastapi.tiangolo.com/) - Xử lý ảnh và chạy mô hình AI.
*   **Cơ sở dữ liệu & Auth:**
    *   **Firebase Authentication:** Đăng nhập (Google, Email).
    *   **Firebase Firestore:** Lưu trữ thông tin người dùng, bác sĩ, lịch sử quét.
    *   **Firebase Realtime Database:** Hệ thống chat thời gian thực.
*   **Video Call Service:** [ZegoCloud](https://www.zegocloud.com/).
*   **State Management:** Provider / StreamBuilder.

## 🚀 Hướng dẫn Cài đặt & Chạy Dự án

### Yêu cầu Tiên quyết
*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   [Python 3.8+](https://www.python.org/downloads/)
*   Tài khoản Firebase & ZegoCloud (đã cấu hình trong code).

### Bước 1: Cài đặt Dependencies Frontend
Tại thư mục gốc của dự án:
```bash
flutter pub get
```

### Bước 2: Khởi chạy Backend AI
Di chuyển vào thư mục backend và cài đặt thư viện Python (nếu chưa):
```bash
cd backend
pip install -r requirements.txt  # (Nếu có file requirements)
# Các thư viện chính: fastapi, uvicorn, tensorflow, numpy, pillow
```

Khởi chạy server:
```bash
uvicorn server:app --reload
```
*   Server sẽ chạy tại: `http://127.0.0.1:8000`

### Bước 3: Chạy Ứng dụng Flutter
Mở một terminal mới tại thư mục gốc dự án:
```bash
flutter run
```
*   **Lưu ý:**
    *   Để test trên máy ảo Android, hãy đảm bảo Backend đang lắng nghe hoặc dùng `adb reverse tcp:8000 tcp:8000`.
    *   Trong code `api_service.dart`, URL backend được cấu hình tự động cho Android Emulator (`10.0.2.2`) và Web/Desktop (`localhost`).

## 📂 Cấu trúc Thư mục Chính

```
lib/
├── models/         # Data models (Doctor, Message, User...)
├── screens/        # Các màn hình UI
│   ├── auth/       # Đăng nhập/Đăng ký
│   ├── consult/    # Danh sách bác sĩ, Chat, Video Call
│   ├── history/    # Lịch sử quét
│   └── scan/       # Camera & Kết quả phân tích
├── services/       # Logic xử lý (API, Firebase, Upload...)
├── utils/          # Tiện ích (Màu sắc, Responsive...)
└── main.dart       # Entry point
backend/
├── server.py       # FastAPI Server
└── models/         # Chứa file model .keras/.h5
```

---
**DermaAI Team**
