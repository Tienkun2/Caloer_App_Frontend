# Hướng dẫn chạy Caloer App

## Bước 1: Cài đặt Flutter

### Windows:
1. Tải Flutter SDK từ: https://docs.flutter.dev/get-started/install/windows
2. Giải nén vào thư mục (ví dụ: `C:\src\flutter`)
3. Thêm Flutter vào PATH:
   - Mở "Environment Variables"
   - Thêm `C:\src\flutter\bin` vào PATH
4. Chạy lệnh kiểm tra:
   ```bash
   flutter doctor
   ```

### Hoặc sử dụng Git để clone Flutter:
```bash
git clone https://github.com/flutter/flutter.git -b stable
```

## Bước 2: Cài đặt dependencies

Mở terminal trong thư mục dự án và chạy:

```bash
flutter pub get
```

## Bước 3: Kiểm tra thiết bị

Kiểm tra thiết bị/emulator có sẵn:
```bash
flutter devices
```

## Bước 4: Chạy ứng dụng

### Chạy trên Android/iOS emulator:
```bash
flutter run
```

### Chạy trên thiết bị cụ thể:
```bash
flutter run -d <device-id>
```

### Chạy trên web:
```bash
flutter run -d chrome
```

### Chạy trên Windows:
```bash
flutter run -d windows
```

## Lưu ý quan trọng:

1. **Backend API**: Ứng dụng cần backend server chạy ở:
   - Main API: `http://192.168.1.11:8080` (có thể thay đổi trong `lib/config/ApiConfig.dart`)
   - AI Service: `http://127.0.0.1:8000`

2. **Android Studio/Xcode**: Cần cài đặt để build cho Android/iOS

3. **Permissions**: Ứng dụng sử dụng:
   - Pedometer (đếm bước)
   - Camera (quét barcode)
   - Microphone (speech to text)
   - Notifications

## Troubleshooting:

- Nếu gặp lỗi về dependencies: `flutter pub get`
- Nếu gặp lỗi về build: `flutter clean` rồi `flutter pub get`
- Kiểm tra Flutter: `flutter doctor -v`


