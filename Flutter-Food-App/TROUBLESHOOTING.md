# Troubleshooting & Common Issues

## 🔧 Installation & Setup Issues

### Issue 1: "Cannot find package 'shared_preferences'"
**Solution:**
```bash
flutter pub get
# or
flutter pub upgrade shared_preferences
```

Ensure in `pubspec.yaml`:
```yaml
dependencies:
  shared_preferences: ^2.0.0  # or latest version
```

---

### Issue 2: "Import errors for new models/services"
**Solution:**
Make sure the file paths are correct in imports:
```dart
// Correct:
import 'models/cart_item.dart';
import 'services/cart_service.dart';
import 'screens/cart_page.dart';

// Wrong:
import '../models/cart_item.dart';  // If in same directory level
```

---

### Issue 3: "API base URL not found"
**Solution:**
Ensure you've updated the base URL in:
1. `lib/config/api_config.dart` - Main configuration
2. `lib/dashboard.dart` - CartPage initialization
3. Any other place where services are initialized

Check for hardcoded URLs like:
```dart
// OLD - needs updating:
baseUrl: 'http://localhost:3000'

// NEW - update to your backend:
baseUrl: 'http://your-backend-url:3000'
```

---

## 🛒 Cart Functionality Issues

### Issue 1: "Cart items not persisting after app restart"
**Diagnosis:**
```dart
// Check if SharedPreferences is initialized in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // This is required
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(token: prefs.getString('token')));
}
```

**Solution:**
- Verify `WidgetsFlutterBinding.ensureInitialized()` is called before SharedPreferences
- Check if running on emulator/device with storage available
- Try clearing app cache: `flutter clean`

---

### Issue 2: "Cart count badge not updating"
**Problem:** The badge shows "0" even after adding items

**Solution:**
```dart
// In dashboard.dart, ensure this is called:
void _updateCartCount() async {
  final count = await _cartService.getCartItemCount();
  setState(() => _cartItemCount = count);
}

// Should be called after:
// 1. Initializing CartService
// 2. Returning from CartPage
// 3. After any cart modification
```

**Fix:**
```dart
// Add this after returning from CartPage:
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _updateCartCount();
  }
}
```

---

### Issue 3: "Duplicate items not increasing quantity"
**Problem:** Adding same item twice creates two entries instead of increasing quantity

**Solution:**
Ensure `CartItem.id` is consistent:
```dart
// Wrong:
CartItem(
  id: widget.foodItem["name"],  // Using name as ID
  ...
)

// Correct:
CartItem(
  id: widget.foodItem["id"] ?? widget.foodItem["name"],  // Use unique ID
  ...
)

// Ensure backend or data source provides unique IDs
```

---

### Issue 4: "Cannot remove items from cart"
**Problem:** Remove button doesn't work

**Solution:**
```dart
// Check that itemId matches exactly
void _removeItem(String itemId) async {
  print('Removing: $itemId');  // Debug
  await _cartService.removeFromCart(itemId);
  _loadCartItems();
}

// Verify CartItem.id is set correctly:
print('Cart item: ${item.id}');  // Should print the ID
```

---

## 💳 Payment Issues

### Issue 1: "Payment URL not opening in browser"
**Problem:** Clicking checkout does nothing or shows error

**Solution:**
```dart
// Check url_launcher is properly imported and available
import 'package:url_launcher/url_launcher.dart';

// Ensure URL is valid:
print('Payment URL: $paymentUrl');  // Debug URL

// Test with a valid URL first:
if (await canLaunchUrl(Uri.parse(paymentUrl))) {
  await launchUrl(
    Uri.parse(paymentUrl),
    mode: LaunchMode.externalApplication,
  );
} else {
  print('Cannot launch URL: $paymentUrl');
}
```

Check `pubspec.yaml` for:
```yaml
url_launcher: ^6.0.0  # or latest version
```

---

### Issue 2: "Order creation fails with 401 error"
**Problem:** "Unauthorized" error when creating order

**Solution:**
```dart
// Ensure token is valid:
print('Token: $token');

// Check Authorization header is set:
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',  // Must be present
},

// Token might be expired, need to refresh:
if (JwtDecoder.isExpired(token)) {
  print('Token expired, need to re-login');
  // Redirect to login
}
```

---

### Issue 3: "Payment status page shows 'Unknown'"
**Problem:** Cannot retrieve payment status

**Solution:**
```dart
// Check payment API endpoint:
// Should be: GET /payments/check-status/{orderId}

// Verify orderId is correct:
print('Order ID: $orderId');

// Check backend is returning correct response format:
{
  "status": true,
  "success": {
    "orderId": "123...",
    "amount": 50.00,
    "status": "SUCCESS",
    ...
  }
}

// Retry fetching:
void _fetchPaymentStatus() async {
  try {
    final result = await _paymentService.checkPaymentStatus(widget.orderId);
    if (result['status']) {
      setState(() {
        _payment = Payment.fromJson(result['payment']);
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error fetching status: $e');
  }
}
```

---

### Issue 4: "VNPAY sandbox test card not working"
**Problem:** Payment fails even with test credentials

**Credentials:**
- Card: `4111111111111111`
- Expiry: `12/30` (MM/YY format)
- OTP: `123456`
- Cardholder: Any name

**Solutions:**
- Verify you're using sandbox environment, not production
- Check VNPAY sandbox status (sometimes down for maintenance)
- Ensure backend VNPAY configuration is correct
- Try different test card if available

**Test cards for Sandbox:**
- Visa: `4111111111111111`
- MasterCard: `5555555555554444`
- JCB: `3530142519041013`

---

## 🌐 Network & API Issues

### Issue 1: "Connection refused to localhost:3000"
**Problem:** Cannot connect to backend

**Solution:**
```dart
// Check if backend is running:
// Terminal: npm start (in nodejs_backend directory)

// Verify correct URL:
baseUrl: 'http://localhost:3000'

// For physical device/different machine:
baseUrl: 'http://192.168.x.x:3000'  // Use machine IP, not localhost

// Get your machine IP:
// Windows: ipconfig
// Mac/Linux: ifconfig
```

---

### Issue 2: "CORS errors from API"
**Problem:** "Access denied" or CORS-related errors

**Solution:**
Ensure backend has CORS configured:
```typescript
// In your Express backend (nodejs):
const cors = require('cors');
app.use(cors({
  origin: ['http://localhost:8080', 'http://localhost:3000'],
  credentials: true,
}));
```

---

### Issue 3: "API returns empty or null data"
**Problem:** Services get null or undefined data

**Solution:**
```dart
// Add logging to debug:
print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');

// Check response format:
// Should be valid JSON

// Handle null/empty cases:
if (response.body.isEmpty) {
  print('Empty response');
  return {'status': false, 'message': 'Empty response'};
}

// Parse safely:
final data = jsonDecode(response.body);
if (data['success'] == null) {
  print('No success data in response');
}
```

---

## 🎨 UI Issues

### Issue 1: "Cart page shows blank/doesn't load items"
**Solution:**
```dart
// Check FutureBuilder is set up correctly:
FutureBuilder<List<CartItem>>(
  future: _loadCartItems(),  // Should be a Future
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    // ...
  }
)

// Ensure _loadCartItems() is async:
void _loadCartItems() async {
  final items = await _cartService.getCartItems();
  setState(() => _cartItems = items);
}
```

---

### Issue 2: "Images not loading in cart"
**Problem:** Image URLs show as broken

**Solution:**
```dart
// Ensure imageUrl is correct:
print('Image URL: ${item.imageUrl}');

// Add error handling:
Image.network(
  item.imageUrl,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported),
    );
  },
)

// For local assets, use:
Image.asset(item.imageUrl)

// For both:
if (item.imageUrl.startsWith('http')) {
  Image.network(item.imageUrl)
} else {
  Image.asset(item.imageUrl)
}
```

---

### Issue 3: "Total price not calculating correctly"
**Solution:**
```dart
double _getTotalPrice() {
  double total = 0;
  for (var item in _cartItems) {
    print('${item.name}: ${item.price} x ${item.quantity} = ${item.totalPrice}');
    total += item.totalPrice;
  }
  print('Total: $total');
  return total;
}

// Or simpler:
double _getTotalPrice() {
  return _cartItems.fold<double>(
    0.0,
    (sum, item) => sum + item.totalPrice,
  );
}

// Ensure CartItem.totalPrice is correct:
double get totalPrice => price * quantity;
```

---

## 📱 Device-Specific Issues

### Issue 1: "Works on emulator but not on physical device"
**Common causes:**
- Different network/IP address
- Permissions not granted
- Storage issues

**Solutions:**
```dart
// Check IP address for physical device:
// Emulator: http://localhost:3000
// Physical device: http://192.168.1.x:3000

// Grant permissions in AndroidManifest.xml:
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

---

### Issue 2: "High RAM usage / App crashes"
**Solution:**
Optimize image loading:
```dart
// Limit image cache:
imageCache.maximumSize = 10;  // Limit to 10 images
imageCache.maximumSizeBytes = 50 * 1024 * 1024;  // 50MB max

// Use thumbnail/compressed images where possible
// Implement pagination for large lists
```

---

## 🐛 Debugging Tips

### Enable Verbose Logging:
```bash
flutter run -v
```

### Add Debug Prints:
```dart
print('=== DEBUG: CartService ===');
print('Saving ${items.length} items');
print('Total: ${total}');
```

### Check SharedPreferences Content:
```dart
void debugPrintSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  for (var key in keys) {
    print('$key: ${prefs.get(key)}');
  }
}
```

### Test API Endpoints Directly:
```bash
# Using curl or Postman:
curl -X POST http://localhost:3000/orders/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"items": [...], "totalAmount": 50}'
```

---

## 📞 Getting Help

If issues persist:

1. **Check the logs:** `flutter logs`
2. **Review error messages** carefully
3. **Check backend logs** for API errors
4. **Refer to documentation** in the repo
5. **Create minimal test case** to isolate issue
6. **Search for similar issues** online (Stack Overflow, GitHub issues)

---

**Last Updated:** 2024
**For more help, see:** CART_AND_PAYMENT_SETUP.md, CART_QUICK_START.md
