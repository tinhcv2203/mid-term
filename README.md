📌 Mid-Term Flutter Project
🛠️ Ứng dụng Flutter hỗ trợ đăng nhập, thêm, sửa, xóa sản phẩm với Firebase

🚀 1. Cài đặt
Yêu cầu
Flutter SDK (Phiên bản mới nhất)
Firebase Console (Đã thiết lập Authentication, Firestore, Storage nếu cần)
Android Studio hoặc VS Code
Các bước cài đặt
1️⃣ Clone dự án
git clone https://github.com/tinhcv2203/mid-term.git
cd mid-term
2️⃣ Cài đặt dependencies
flutter pub get
3️⃣ Cấu hình Firebase
Tải file google-services.json (Android) hoặc GoogleService-Info.plist (iOS) từ Firebase Console.
Đặt file vào thư mục:
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
4️⃣ Chạy ứng dụng
flutter run
🔑 2. Chức năng chính
✅ Đăng nhập/Đăng ký
Xác thực bằng Firebase Authentication (Email & Password).
✅ Thêm sản phẩm
Người dùng có thể nhập tên, giá, ảnh và lưu vào Firestore.
✅ Sửa sản phẩm
Chỉnh sửa thông tin sản phẩm đã thêm.
✅ Xóa sản phẩm
Xóa sản phẩm khỏi danh sách và Firestore.
✅ Upload ảnh

Ảnh có thể lưu trữ trên Firebase Storage hoặc Imgur API.
📸 3. Giao diện Màn Hình
Màn hình	Ảnh minh họa
Đăng nhập
Trang chủ
Thêm sản phẩm
🛠 4. Cấu trúc thư mục
lib/
│── main.dart
│── screens/
│   │── homeScreen.dart  # Trang chủ
│   │── loginScreen.dart  # Đăng nhập
│── services/
│   │── auth_service.dart  # Xử lý Firebase Auth
│   │── firestore_service.dart  
│── widgets/
│   │── product_card.dart  # Widget hiển thị sản phẩm
🔗 5. Liên hệ & Đóng góp
📧 Email: tinhcv2203@gmail.com
🔗 GitHub: (https://github.com/tinhcv2203/)

🚀 Chạy thử ngay!
flutter run
