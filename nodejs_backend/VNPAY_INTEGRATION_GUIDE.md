# VNPAY Payment Gateway Integration Guide

## Mục lục
1. [Thông tin cấu hình](#thông-tin-cấu-hình)
2. [Cài đặt Backend](#cài-đặt-backend)
3. [Cài đặt Flutter Frontend](#cài-đặt-flutter-frontend)
4. [API Endpoints](#api-endpoints)
5. [Luồng thanh toán](#luồng-thanh-toán)
6. [Testing](#testing)
7. [Triển khai Production](#triển-khai-production)

---

## Thông tin cấu hình

### Sandbox (Test) Environment

```
Terminal ID / Mã Website (vnp_TmnCode): G2P4PHXX
Secret Key / Chuỗi bí mật (vnp_HashSecret): 7IG2TM2Y3F8ONYPAPV84W7AIGLSGNIUK
Payment URL: https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
Merchant Admin: https://sandbox.vnpayment.vn/merchantv2/
Email: hophuoc4so9@gmail.com
```

### Test Card

```
Bank: NCB
Card Number: 9704198526191432198
Cardholder Name: NGUYEN VAN A
Issue Date: 07/15
OTP Password: 123456
```

---

## Cài đặt Backend

### 1. Cài đặt Dependencies

```bash
cd nodejs_backend
npm install
# Đã cài đặt: axios, crypto (built-in)
```

### 2. Cấu hình Environment Variables

Sao chép `.env.example` thành `.env`:

```bash
cp .env.example .env
```

Cập nhật các biến VNPAY trong `.env`:

```env
# VNPAY Configuration
VNPAY_TMN_CODE=G2P4PHXX
VNPAY_HASH_SECRET=7IG2TM2Y3F8ONYPAPV84W7AIGLSGNIUK
VNPAY_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
VNPAY_RETURN_URL=http://localhost:3000/payments/vnpay-return
VNPAY_IPN_URL=http://localhost:3000/payments/vnpay-ipn
VNPAY_API_URL=https://sandbox.vnpayment.vn/merchant_weblogic/api/transaction
FLUTTER_APP_URL=http://localhost:8080
```

### 3. File cấu trúc Backend

```
src/
├── config/
│   └── vnpay.config.ts          # VNPAY configuration & helpers
├── models/
│   └── payment.model.ts         # Payment database schema
├── services/
│   └── vnpay.service.ts         # VNPAY business logic
├── controller/
│   └── payment.controller.ts    # Payment API endpoints
└── routes/
    └── payment.route.ts         # Payment routes
```

### 4. Database Schema

Payment Model bao gồm các trường:

- `userId`: ID của người dùng
- `orderId`: Mã đơn hàng duy nhất (timestamp + random)
- `amount`: Số tiền (VND)
- `status`: Trạng thái (PENDING, SUCCESS, FAILED, REFUNDED)
- `paymentUrl`: URL thanh toán VNPAY
- `transactionNo`: Mã giao dịch VNPAY
- `vnpayCode`: Response code từ VNPAY
- `bankCode`: Mã ngân hàng
- `cardType`: Loại thẻ

### 5. Chạy Backend

```bash
npm run dev
```

Server sẽ chạy trên `http://localhost:3000`

---

## Cài đặt Flutter Frontend

### 1. Thêm Dependencies

Mở `pubspec.yaml` và thêm:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  url_launcher: ^6.1.0
```

Chạy:

```bash
flutter pub get
```

### 2. Cấu hình URL Backend

Trong app của bạn, khi khởi tạo `PaymentService`:

```dart
final paymentService = PaymentService(
  baseUrl: 'http://localhost:3000',
  authToken: 'your_jwt_token',
);
```

### 3. File cấu trúc Flutter

```
lib/
├── models/
│   └── payment.dart                 # Payment data model
├── services/
│   └── payment_service.dart         # API service
└── screens/
    ├── payment_screen.dart          # Thanh toán screen
    └── payment_result_screen.dart   # Kết quả thanh toán screen
```

### 4. Thêm Screens vào Navigation

Trong `main.dart` hoặc routing logic:

```dart
// Tới Payment Screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => PaymentScreen(
      baseUrl: 'http://localhost:3000',
      authToken: authToken,
    ),
  ),
);

// Xử lý deep link cho payment result
// (Từ VNPAY return URL)
if (uri.path.contains('payment-result')) {
  final orderId = uri.queryParameters['orderId'];
  final status = uri.queryParameters['status'];
  
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PaymentResultScreen(
        orderId: orderId ?? '',
        status: status ?? 'FAILED',
        baseUrl: 'http://localhost:3000',
        authToken: authToken,
      ),
    ),
  );
}
```

---

## API Endpoints

### 1. Tạo Thanh toán

**POST** `/payments/create-payment`

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Body:**
```json
{
  "amount": 100000,
  "description": "Order #12345"
}
```

**Response:**
```json
{
  "status": true,
  "success": {
    "orderId": "1715425400000123456",
    "paymentUrl": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?vnp_Amount=10000000&...",
    "amount": 100000
  }
}
```

### 2. Kiểm tra Trạng thái Thanh toán

**GET** `/payments/check-status/{orderId}`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "status": true,
  "success": {
    "orderId": "1715425400000123456",
    "amount": 100000,
    "status": "SUCCESS",
    "createdAt": "2024-05-10T10:30:00Z",
    "completedAt": "2024-05-10T10:32:15Z",
    "transactionNo": "12345678",
    "bankCode": "NCB"
  }
}
```

### 3. Lấy Lịch sử Thanh toán

**GET** `/payments/user-payments?status=SUCCESS&limit=10&skip=0`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "status": true,
  "success": {
    "total": 5,
    "payments": [...]
  }
}
```

### 4. VNPAY Return URL Callback

**GET** `/payments/vnpay-return?vnp_Amount=10000000&vnp_BankCode=NCB&...`

*Tự động redirect về Flutter app với payment result*

### 5. VNPAY IPN Callback (Server-to-Server)

**GET** `/payments/vnpay-ipn?vnp_Amount=10000000&vnp_BankCode=NCB&...`

**Response:**
```json
{
  "RspCode": "00",
  "Message": "Confirm success"
}
```

---

## Luồng thanh toán

### Quy trình thanh toán hoàn chỉnh:

```
1. User nhấn nút "Thanh toán qua VNPAY"
   ↓
2. Flutter gọi API: POST /payments/create-payment
   ↓
3. Backend tạo Payment record (status: PENDING)
   ↓
4. Backend trả về paymentUrl từ VNPAY
   ↓
5. Flutter mở URL thanh toán (WebView hoặc External Browser)
   ↓
6. User nhập thông tin thẻ và OTP trên VNPAY
   ↓
7. VNPAY gửi IPN callback tới Backend (server-to-server)
   ↓
8. Backend cập nhật Payment status = SUCCESS
   ↓
9. VNPAY redirect user tới Flutter app qua return URL
   ↓
10. Flutter hiển thị Payment Result Screen
```

### Checksum Verification Flow:

```
Request từ VNPAY → Backend
        ↓
Lấy tất cả parameters (trừ vnp_SecureHash)
        ↓
Sắp xếp alphabetically
        ↓
Hash với HMAC-SHA512 + secret key
        ↓
So sánh với vnp_SecureHash từ request
        ↓
Nếu match → Xử lý request
Nếu không → Reject
```

---

## Testing

### Test Case 1: Thanh toán thành công

1. Mở Payment Screen
2. Nhập Amount: `100000`
3. Nhập Description: `Test Order`
4. Nhấn "Thanh toán qua VNPAY"
5. Sử dụng test card: `9704198526191432198`
6. OTP: `123456`
7. Xác nhận thanh toán
8. Kiểm tra Payment Result Screen
9. Kiểm tra database: Payment status = `SUCCESS`

### Test Case 2: Kiểm tra Status

```bash
curl -X GET "http://localhost:3000/payments/check-status/1715425400000123456" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test Case 3: Lấy Lịch sử

```bash
curl -X GET "http://localhost:3000/payments/user-payments?status=SUCCESS" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test Card tương tự trên Sandbox:

```
9704198526191432198
CVV: 123456
Expiry: 07/15
Cardholder: NGUYEN VAN A
```

---

## Triển khai Production

### 1. Lấy Thông tin Production từ VNPAY

```
Terminal ID: [Liên hệ VNPAY]
Secret Key: [Liên hệ VNPAY]
Payment URL: https://vnpayment.vn/paymentv2/vpcpay.html
IPN URL: https://yourdomain.com/payments/vnpay-ipn
Return URL: https://yourflutterapp.com/payment-result
```

### 2. Cập nhật Environment Variables

```env
# Production
NODE_ENV=production
VNPAY_URL=https://vnpayment.vn/paymentv2/vpcpay.html
VNPAY_TMN_CODE=your_production_tmn_code
VNPAY_HASH_SECRET=your_production_secret_key
VNPAY_RETURN_URL=https://yourdomain.com/payments/vnpay-return
VNPAY_IPN_URL=https://yourdomain.com/payments/vnpay-ipn
FLUTTER_APP_URL=https://yourflutterapp.com
```

### 3. Security Checklist

- ✅ Sử dụng HTTPS cho tất cả URLs
- ✅ Verify checksum cho tất cả VNPAY callbacks
- ✅ Lưu trữ Secret Key an toàn (environment variables)
- ✅ Implement rate limiting trên IPN endpoint
- ✅ Log tất cả payment transactions
- ✅ Validate user authentication trước khi xử lý payment
- ✅ Implement retry logic cho IPN failures
- ✅ Monitor payment failures
- ✅ Setup alerts cho payment errors

### 4. Swagger Documentation

Sau khi deploy, Swagger docs sẽ có sẵn tại:

```
http://yourdomain.com/api-docs
```

Tất cả Payment endpoints đã có Swagger annotations.

### 5. Database Migration

Nếu cần migrate data:

```bash
# Backup data
mongodump --db food_app --out ./backup

# Migrate
mongorestore ./backup
```

---

## Troubleshooting

### Lỗi: "Invalid checksum"

- Kiểm tra Secret Key có đúng không
- Kiểm tra tất cả parameters được include
- Kiểm tra encoding UTF-8

### Lỗi: "Payment not found"

- Kiểm tra orderId có đúng không
- Kiểm tra user authentication
- Kiểm tra payment record trong database

### VNPAY URL không mở được

- Kiểm tra network connectivity
- Kiểm tra VNPAY_URL environment variable
- Kiểm tra request parameters có valid không

### IPN Callback không nhận được

- Kiểm tra IPN URL có public access không
- Kiểm tra firewall/security rules
- Kiểm tra server logs
- Test bằng VNPAY sandbox testing tool

---

## Liên hệ VNPAY Support

```
Email: support.vnpayment@vnpay.vn
Hotline: 1900 55 55 77
Website: https://vnpayment.vn
```

---

## Tài liệu Tham khảo

- [VNPAY Integration Documentation](https://sandbox.vnpayment.vn/apis/docs/thanh-toan-pay/pay.html)
- [VNPAY Demo](https://sandbox.vnpayment.vn/apis/vnpay-demo/)
- [Code Demo](https://sandbox.vnpayment.vn/apis/vnpay-demo/code-demo-tích-hợp)
- [Merchant Admin](https://sandbox.vnpayment.vn/merchantv2/)
- [SIT Testing](https://sandbox.vnpayment.vn/vnpaygw-sit-testing/user/login)

---

**Cập nhật lần cuối:** 2024-05-11
**Phiên bản:** 1.0
**Trạng thái:** Production Ready
