# VNPAY Payment Integration - Flutter Implementation Guide

## Mục lục
1. [Yêu cầu](#yêu-cầu)
2. [Cài đặt Package](#cài-đặt-package)
3. [Cấu hình App](#cấu-hình-app)
4. [Code Example](#code-example)
5. [Deep Linking](#deep-linking)
6. [Best Practices](#best-practices)

---

## Yêu cầu

- Flutter SDK >= 3.0
- Dart >= 3.0
- `http` package
- `url_launcher` package
- Backend VNPAY integration (đã setup)

---

## Cài đặt Package

### 1. Thêm Dependencies

Mở `pubspec.yaml` trong folder `Flutter-Food-App/`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  url_launcher: ^6.1.0
  # Nếu sử dụng local storage cho auth tokens
  flutter_secure_storage: ^9.0.0
```

### 2. Chạy Pub Get

```bash
flutter pub get
```

### 3. Android Configuration

Mở `android/app/build.gradle`:

```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 21
    }
}
```

### 4. iOS Configuration

Mở `ios/Runner/Info.plist` và thêm:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>https</string>
    <string>http</string>
</array>
```

---

## Cấu hình App

### 1. File Cấu trúc

```
lib/
├── config/
│   └── app_config.dart              # API URLs
├── models/
│   └── payment.dart                 # Payment model
├── screens/
│   ├── payment_screen.dart          # Thanh toán screen
│   └── payment_result_screen.dart   # Kết quả screen
├── services/
│   ├── auth_service.dart            # Auth & tokens
│   └── payment_service.dart         # Payment API
├── main.dart
└── ...
```

### 2. App Configuration

Tạo `lib/config/app_config.dart`:

```dart
class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000';
  
  // Payment Configuration
  static const String paymentBaseUrl = '$apiBaseUrl/payments';
  
  // Timeout
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Environment
  static const String environment = 'development';
}
```

### 3. Auth Service

Tạo `lib/services/auth_service.dart`:

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  String? _authToken;
  
  String? get authToken => _authToken;
  
  Future<void> login(String email, String password) async {
    // Login implementation
    // Set _authToken
  }
  
  Future<void> logout() async {
    _authToken = null;
  }
  
  bool get isAuthenticated => _authToken != null;
}
```

---

## Code Example

### 1. Sử dụng Payment Service

```dart
// Initialize Payment Service
final paymentService = PaymentService(
  baseUrl: AppConfig.apiBaseUrl,
  authToken: AuthService().authToken,
);

// Create payment
final result = await paymentService.createPayment(
  amount: 100000,
  description: 'Order #12345',
);

if (result['status'] == true) {
  print('Order ID: ${result['orderId']}');
  print('Payment URL: ${result['paymentUrl']}');
}
```

### 2. Payment Screen Implementation

```dart
import 'package:flutter/material.dart';
import 'screens/payment_screen.dart';

// Navigate to payment screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => PaymentScreen(
      baseUrl: AppConfig.apiBaseUrl,
      authToken: AuthService().authToken ?? '',
    ),
  ),
);
```

### 3. Xử lý Payment Result

```dart
// Trong main.dart hoặc app.dart
void handleDeepLink(Uri uri) {
  if (uri.path.contains('payment-result')) {
    final orderId = uri.queryParameters['orderId'];
    final status = uri.queryParameters['status'];
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          orderId: orderId ?? '',
          status: status ?? 'FAILED',
          baseUrl: AppConfig.apiBaseUrl,
          authToken: AuthService().authToken ?? '',
        ),
      ),
    );
  }
}
```

---

## Deep Linking

### Android Setup

1. Mở `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="localhost"
        android:pathPrefix="/payment-result" />
</intent-filter>
```

2. Hoặc cho production:

```xml
<data
    android:scheme="https"
    android:host="yourdomain.com"
    android:pathPrefix="/payment-result" />
```

### iOS Setup

1. Mở `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>foodapp</string>
        </array>
    </dict>
</array>
```

### Flutter App Integration

Cài đặt package `uni_links` hoặc `app_links`:

```bash
flutter pub add app_links
```

Trong `main.dart`:

```dart
import 'package:app_links/app_links.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  late StreamSubscription<Uri> _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _deepLinkSubscription = _appLinks.uriStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path.contains('payment-result')) {
      final orderId = uri.queryParameters['orderId'];
      final status = uri.queryParameters['status'];
      
      // Navigate to payment result
      // NavigatorState.of(context).push(...)
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... app configuration
    );
  }
}
```

---

## Best Practices

### 1. Token Management

```dart
// Lưu token an toàn
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

### 2. Error Handling

```dart
// Xử lý lỗi khi thanh toán
Future<void> handlePaymentError(String message) async {
  // Log error
  print('Payment Error: $message');
  
  // Show user-friendly message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    ),
  );
}
```

### 3. Retry Logic

```dart
// Retry failed payment request
Future<T> retryRequest<T>(
  Future<T> Function() request, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  int attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      return await request();
    } catch (e) {
      attempt++;
      if (attempt >= maxRetries) rethrow;
      await Future.delayed(delay * attempt);
    }
  }
  
  throw Exception('Max retries exceeded');
}
```

### 4. Loading States

```dart
// Manage loading states
class PaymentViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> createPayment(double amount, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Create payment
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 5. Payment Status Polling

```dart
// Poll payment status
Future<void> pollPaymentStatus(
  String orderId, {
  Duration interval = const Duration(seconds: 3),
  int maxAttempts = 20,
}) async {
  int attempt = 0;
  
  while (attempt < maxAttempts) {
    final result = await paymentService.checkPaymentStatus(orderId);
    
    if (result['status'] == true) {
      final payment = result['payment'];
      
      if (payment['status'] != 'PENDING') {
        // Payment completed
        return;
      }
    }
    
    await Future.delayed(interval);
    attempt++;
  }
}
```

### 6. Analytics & Logging

```dart
// Log payment events
class PaymentLogger {
  static void logPaymentCreated(String orderId, double amount) {
    print('Payment created: $orderId, amount: $amount');
    // Send to analytics
  }
  
  static void logPaymentSuccess(String orderId, String transactionNo) {
    print('Payment success: $orderId, transaction: $transactionNo');
    // Send to analytics
  }
  
  static void logPaymentFailed(String orderId, String reason) {
    print('Payment failed: $orderId, reason: $reason');
    // Send to analytics
  }
}
```

---

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Payment Service', () {
    late PaymentService paymentService;
    
    setUp(() {
      paymentService = PaymentService(
        baseUrl: 'http://localhost:3000',
        authToken: 'test_token',
      );
    });
    
    test('Create payment returns valid response', () async {
      final result = await paymentService.createPayment(
        amount: 100000,
        description: 'Test',
      );
      
      expect(result['status'], equals(true));
      expect(result['orderId'], isNotEmpty);
      expect(result['paymentUrl'], isNotEmpty);
    });
  });
}
```

### Widget Tests

```dart
void main() {
  group('Payment Screen', () {
    testWidgets('Shows payment form', (WidgetTester tester) async {
      await tester.pumpWidget(
        const PaymentScreen(
          baseUrl: 'http://localhost:3000',
          authToken: 'test_token',
        ),
      );
      
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Thanh toán qua VNPAY'), findsOneWidget);
    });
  });
}
```

---

## Troubleshooting

### URL Launcher không hoạt động

```dart
// Kiểm tra URL có hợp lệ không
try {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
} catch (e) {
  print('Launch error: $e');
  // Fallback
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Cannot open payment page: $e')),
  );
}
```

### Deep Link không nhận được

- Kiểm tra Android intent-filter
- Kiểm tra iOS URL schemes
- Test bằng adb: `adb shell am start -a android.intent.action.VIEW -d "https://localhost/payment-result?orderId=123&status=SUCCESS"`

### Token expiration

```dart
// Handle token expiration
if (response.statusCode == 401) {
  // Token expired
  await AuthService().logout();
  // Redirect to login
  Navigator.of(context).pushNamedAndRemoveUntil(
    '/login',
    (Route<dynamic> route) => false,
  );
}
```

---

## Liên hệ & Support

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra Backend logs
2. Kiểm tra VNPAY Sandbox Admin
3. Liên hệ VNPAY support: support.vnpayment@vnpay.vn

---

**Cập nhật lần cuối:** 2024-05-11
**Phiên bản:** 1.0
**Status:** Ready for Development
