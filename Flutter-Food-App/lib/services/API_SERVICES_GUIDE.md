# API Services Architecture

## Overview
All API calls in the Flutter Food App are centralized in the `lib/services/` directory. This ensures:
- ✅ Single source of truth for all API logic
- ✅ Easy to maintain and update endpoints
- ✅ Consistent error handling
- ✅ Reusable code across screens
- ✅ Better testing capabilities

## Service Structure

### 1. **AuthService** (`auth_service.dart`)
Handles all authentication-related API calls.

**Methods:**
- `registerUser()` - User registration
- `loginUser()` - User login
- `forgotPassword()` - Forgot password request
- `resetPassword()` - Password reset with OTP
- `sendOTP()` - Send OTP to email
- `verifyOTP()` - Verify OTP
- `resendOTP()` - Resend OTP

**Usage:**
```dart
var result = await AuthService.loginUser(
  email: 'user@example.com',
  password: 'password123'
);
```

---

### 2. **CategoryService** (`category_service.dart`)
Handles category-related API calls.

**Methods:**
- `getCategories()` - Get all food categories
- `getFoods(categoryId)` - Get foods by category (Legacy - use FoodService instead)

**Usage:**
```dart
var categories = await _categoryService.getCategories();
```

---

### 3. **FoodService** (`food_service.dart`)
Handles food/menu-related API calls. **Recommended over CategoryService.getFoods()**.

**Methods:**
- `getFoodsByCategory(categoryId)` - Get foods for a specific category
- `getAllFoods()` - Get all available foods
- `getFoodById(foodId)` - Get details of a specific food
- `searchFoods(query)` - Search foods by name/description

**Usage:**
```dart
final foodService = FoodService(
  baseUrl: 'http://localhost:3000',
  authToken: userToken,
);

var foods = await foodService.getFoodsByCategory('category123');
var results = await foodService.searchFoods('pizza');
```

---

### 4. **CartService** (`cart_service.dart`)
Handles cart management using local storage (SharedPreferences).

**Methods:**
- `getCartItems()` - Get all items in cart
- `addToCart(item)` - Add item to cart
- `removeFromCart(itemId)` - Remove item from cart
- `updateQuantity(itemId, quantity)` - Update item quantity
- `clearCart()` - Clear entire cart
- `getTotalPrice()` - Calculate total price
- `getTotalQuantity()` - Get total quantity
- `savePaymentStatus()` - Save successful payment info
- `getPaymentHistory()` - Get payment history
- `getLastPaymentStatus()` - Get last payment

**Usage:**
```dart
final cartService = CartService(prefs: sharedPreferences);
await cartService.addToCart(cartItem);
final history = await cartService.getPaymentHistory();
```

---

### 5. **OrderService** (`order_service.dart`)
Handles order-related API calls.

**Methods:**
- `createOrder(items, description)` - Create new order
- `getOrder(orderId)` - Get order details
- `getUserOrders()` - Get all user orders
- `updateOrderStatus(orderId, status)` - Update order status
- `cancelOrder(orderId)` - Cancel an order

**Usage:**
```dart
final orderService = OrderService(
  baseUrl: 'http://localhost:3000',
  authToken: token,
);

final result = await orderService.createOrder(
  items: cartItems,
  description: 'Food Order - 3 items',
);
```

---

### 6. **PaymentService** (`payment_service.dart`)
Handles payment-related API calls (VNPAY integration).

**Methods:**
- `createPayment(amount, description)` - Create VNPAY payment request
- `checkPaymentStatus(orderId)` - Check payment status
- `getUserPayments()` - Get user payment history

**Usage:**
```dart
final paymentService = PaymentService(
  baseUrl: 'http://localhost:3000',
  authToken: token,
);

final result = await paymentService.createPayment(
  amount: 100.00,
  description: 'Order #12345',
);

final status = await paymentService.checkPaymentStatus(orderId);
```

---

## API Configuration

### Centralized Endpoints (`lib/config/api_config.dart`)

All API endpoints are defined in `ApiConfig` and `ApiEndpoints` classes:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const int requestTimeout = 30;
  static const bool enableDebugLogging = true;
}

class ApiEndpoints {
  // Auth
  static const String register = '$baseUrl/users/createUser';
  static const String login = '$baseUrl/users/login';
  
  // Foods
  static String foodsByCategory(String categoryId) => '$baseUrl/categories/getFood/$categoryId';
  
  // Orders
  static const String createOrder = '$baseUrl/users/addOrder';
  
  // Payments
  static const String createPayment = '$baseUrl/payments/create-payment';
}
```

**To update the base URL:**
```dart
// Change in lib/config/api_config.dart
static const String baseUrl = 'http://your-server.com:3000';
```

---

## Error Handling

All services include consistent error handling:

```dart
try {
  final result = await service.someMethod();
  if (result['status']) {
    // Success
  } else {
    // Handle error from backend
    print(result['message']);
  }
} catch (e) {
  // Handle network or other errors
  print('Error: $e');
}
```

---

## Authentication

All services that require authentication accept an `authToken` parameter:

```dart
final orderService = OrderService(
  baseUrl: widget.baseUrl,
  authToken: widget.token,  // JWT token from login
);
```

The token is automatically added to request headers as:
```
Authorization: Bearer $token
```

---

## Request Flow Example

### Complete Payment Flow:
```
User clicks "Proceed to Payment"
    ↓
CartPage calls OrderService.createOrder()
    ↓
OrderService creates order on backend
    ↓
CartPage calls PaymentService.createPayment()
    ↓
PaymentService gets VNPAY payment URL
    ↓
url_launcher opens VNPAY payment page
    ↓
User completes payment on VNPAY
    ↓
CartPage polls PaymentService.checkPaymentStatus()
    ↓
When status = SUCCESS:
    - CartService.savePaymentStatus() saves to local storage
    - CartService.clearCart() clears cart
    - Show success message
```

---

## Best Practices

1. **Use Services, Don't Call HTTP Directly**
   - ❌ Bad: `http.get(Uri.parse('...'))`
   - ✅ Good: `await service.getMethod()`

2. **Check Response Status**
   ```dart
   final result = await service.method();
   if (result['status'] == true) {
     // Handle success
   } else {
     // Handle error
   }
   ```

3. **Always Use Try-Catch**
   ```dart
   try {
     final result = await service.method();
   } catch (e) {
     print('Error: $e');
     // Show error to user
   }
   ```

4. **Pass Token to Services**
   ```dart
   // Get token from SharedPreferences or constructor
   final service = OrderService(
     baseUrl: baseUrl,
     authToken: token,
   );
   ```

5. **Use Consistent Error Messages**
   - Return structured Map with `status` and `message`
   - Log errors for debugging

---

## Adding New Services

To add a new API service:

1. **Create service file** in `lib/services/`
2. **Define endpoints** in `lib/config/api_config.dart`
3. **Implement methods** with consistent error handling
4. **Update documentation** (this file)

Example template:
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewService {
  final String baseUrl;
  final String? authToken;

  NewService({
    required this.baseUrl,
    this.authToken,
  });

  Future<Map<String, dynamic>> getMethod() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return {'status': true, 'data': data['success']};
        } else {
          return {'status': false, 'message': data['message']};
        }
      } else {
        return {'status': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }
}
```

---

## Services Location Map

```
lib/
├── services/
│   ├── auth_service.dart          ← Authentication
│   ├── category_service.dart      ← Categories (Legacy)
│   ├── food_service.dart          ← Foods (Recommended)
│   ├── cart_service.dart          ← Cart Management
│   ├── order_service.dart         ← Orders
│   └── payment_service.dart       ← Payments (VNPAY)
│
├── config/
│   └── api_config.dart            ← Centralized endpoints
│
├── models/
│   ├── cart_item.dart
│   ├── order.dart
│   ├── food.dart
│   └── category.dart
│
└── screens/
    ├── cart_page.dart
    ├── payment_result_page.dart
    └── ...
```

---

**Last Updated:** 2026-05-11
**All API calls are now centralized in services!** ✅
