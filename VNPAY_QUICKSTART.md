# VNPAY Integration - Quick Start Guide

## ⚡ 5 Bước Để Bắt Đầu

### Bước 1: Backend Setup (2-3 phút)

```bash
cd nodejs_backend

# 1. Cài đặt dependencies (nếu chưa)
npm install

# 2. Tạo .env file
cp .env.example .env

# 3. Các thông tin đã có sẵn trong .env:
# VNPAY_TMN_CODE=G2P4PHXX
# VNPAY_HASH_SECRET=7IG2TM2Y3F8ONYPAPV84W7AIGLSGNIUK
# VNPAY_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html

# 4. Chạy backend
npm run dev
# Sẽ chạy trên http://localhost:3000
```

✅ Backend sẵn sàng! Kiểm tra: http://localhost:3000/health

---

### Bước 2: Kiểm tra API Swagger (1 phút)

```bash
# Mở browser và vào
http://localhost:3000/api-docs
```

- Tìm tab **Payments**
- Xem các endpoint:
  - `POST /payments/create-payment`
  - `GET /payments/check-status/{orderId}`
  - `GET /payments/user-payments`

---

### Bước 3: Flutter Setup (3-5 phút)

```bash
cd Flutter-Food-App

# 1. Cài đặt packages
flutter pub add http url_launcher

# 2. Update pubspec.yaml
# Thêm:
# dependencies:
#   http: ^1.1.0
#   url_launcher: ^6.1.0

# 3. Lấy files
# Các files đã được tạo sẵn:
# - lib/services/payment_service.dart
# - lib/models/payment.dart
# - lib/screens/payment_screen.dart
# - lib/screens/payment_result_screen.dart
```

---

### Bước 4: Thêm Payment Screen vào App

```dart
// Trong main.dart
import 'screens/payment_screen.dart';

// Khi user nhấn nút thanh toán
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => PaymentScreen(
      baseUrl: 'http://localhost:3000',
      authToken: 'your_jwt_token',
    ),
  ),
);
```

---

### Bước 5: Test Thanh toán

#### Test Card Info
```
Số thẻ: 9704198526191432198
CVV: 123456
Hạn: 07/15
Chủ thẻ: NGUYEN VAN A
```

#### Test Flow
1. Mở App → Payment Screen
2. Nhập: Amount = `100000`, Description = `Test Order`
3. Nhấn "Thanh toán qua VNPAY"
4. Nhập thông tin test card
5. Xác nhận → Xem kết quả

---

## 📁 Files Đã Tạo

### Backend Files
```
nodejs_backend/
├── src/
│   ├── config/vnpay.config.ts          ✅ Config & helpers
│   ├── models/payment.model.ts         ✅ Database schema
│   ├── services/vnpay.service.ts       ✅ Business logic
│   ├── controller/payment.controller.ts ✅ API endpoints
│   └── routes/payment.route.ts         ✅ Routes
├── .env.example                        ✅ Environment vars
└── VNPAY_INTEGRATION_GUIDE.md          ✅ Full guide
```

### Flutter Files
```
Flutter-Food-App/lib/
├── models/payment.dart                 ✅ Data model
├── services/payment_service.dart       ✅ API service
├── screens/
│   ├── payment_screen.dart             ✅ UI screen
│   └── payment_result_screen.dart      ✅ Result screen
└── VNPAY_FLUTTER_GUIDE.md              ✅ Flutter guide
```

---

## 🔧 Xử Lý Vấn đề Phổ biến

### ❌ "Cannot connect to backend"
```bash
# Kiểm tra backend chạy không
curl http://localhost:3000/health

# Nếu lỗi, chạy lại
cd nodejs_backend && npm run dev
```

### ❌ "Payment URL không mở"
```dart
// Kiểm tra URL_LAUNCHER setup
// Thêm vào pubspec.yaml:
// url_launcher: ^6.1.0
flutter pub get
```

### ❌ "Unauthorized error"
```dart
// Kiểm tra JWT token
// Khi tạo PaymentService, phải pass authToken
const paymentService = PaymentService(
  baseUrl: 'http://localhost:3000',
  authToken: authToken, // ← Phải có
);
```

### ❌ "Checksum invalid"
```
Backend: Kiểm tra VNPAY_HASH_SECRET đúng không
ENV: VNPAY_HASH_SECRET=7IG2TM2Y3F8ONYPAPV84W7AIGLSGNIUK
```

---

## 📱 Test URLs

### Sandbox Admin
```
URL: https://sandbox.vnpayment.vn/merchantv2/
Email: hophuoc4so9@gmail.com
```

### Swagger API Docs
```
Local: http://localhost:3000/api-docs
```

---

## 🚀 Next Steps

### Development
1. ✅ Test thanh toán thành công
2. ✅ Test thanh toán thất bại
3. ✅ Test kiểm tra status payment
4. ✅ Test lịch sử payment

### Testing
- Xem [VNPAY_INTEGRATION_GUIDE.md](./nodejs_backend/VNPAY_INTEGRATION_GUIDE.md)
- Xem [VNPAY_FLUTTER_GUIDE.md](./Flutter-Food-App/VNPAY_FLUTTER_GUIDE.md)

### Production
- Lấy TMN_CODE và SECRET_KEY từ VNPAY
- Update .env với values production
- Test tất cả flows trước deploy

---

## 📞 Liên hệ

### VNPAY Support
```
Email: support.vnpayment@vnpay.vn
Hotline: 1900 55 55 77
Website: https://vnpayment.vn
```

### Documentation
```
Integration Docs: https://sandbox.vnpayment.vn/apis/docs/thanh-toan-pay/pay.html
Demo Portal: https://sandbox.vnpayment.vn/apis/vnpay-demo/
Code Demo: https://sandbox.vnpayment.vn/apis/vnpay-demo/code-demo-tích-hợp
```

---

## ✅ Checklist

- [ ] Backend chạy thành công
- [ ] Kiểm tra Swagger docs
- [ ] Cài đặt Flutter packages
- [ ] Thêm payment screens
- [ ] Test payment flow
- [ ] Kiểm tra database records
- [ ] Review security (checksums, tokens)
- [ ] Chuẩn bị production config

---

**Status:** ✅ Ready to Use
**Last Update:** 2024-05-11
**Version:** 1.0
