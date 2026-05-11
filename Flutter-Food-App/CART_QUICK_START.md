# Shopping Cart & VNPAY Payment - Quick Start Guide

## 📋 What Was Added

### New Files Created:
1. **Models**
   - `lib/models/cart_item.dart` - Cart item model
   - `lib/models/order.dart` - Order model

2. **Services**
   - `lib/services/cart_service.dart` - Shopping cart management
   - `lib/services/order_service.dart` - Order management
   - (Updated) `lib/services/payment_service.dart` - VNPAY payment handling

3. **Screens**
   - `lib/screens/cart_page.dart` - Shopping cart screen
   - `lib/screens/payment_result_page.dart` - Payment result screen

4. **Configuration**
   - `lib/config/api_config.dart` - API endpoints configuration
   - `CART_AND_PAYMENT_SETUP.md` - Detailed documentation

### Updated Files:
- `lib/food_detail_page.dart` - Added "Add to Cart" functionality
- `lib/dashboard.dart` - Added shopping cart icon navigation and cart count badge

---

## 🚀 Quick Setup (3 Steps)

### Step 1: Update Backend URL
Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://your-backend-url:3000';
```

Or update directly in `dashboard.dart` cart navigation:
```dart
CartPage(
  token: widget.token,
  baseUrl: 'http://your-backend-url:3000',
)
```

### Step 2: Verify Dependencies
Ensure `pubspec.yaml` has these packages (should already be there):
```yaml
shared_preferences:
http:
url_launcher:
```

### Step 3: Run the App
```bash
cd Flutter-Food-App
flutter pub get
flutter run
```

---

## 📱 User Flow

### Adding Items to Cart:
1. Click on a food item from the home screen
2. Adjust quantity using + / - buttons
3. Click "Thêm vào giỏ" (Add to Cart)
4. Item is automatically saved to local storage

### Viewing & Managing Cart:
1. Click the cart icon (🛒) in the app bar
2. View all items with images and prices
3. Adjust quantities or remove items
4. See real-time total price

### Checkout:
1. Click "Proceed to Payment"
2. Order is created on the backend
3. VNPAY payment page opens automatically
4. Complete payment using test card:
   - Card: `4111111111111111`
   - Expiry: `12/30`
   - OTP: `123456`
5. Return to app to see payment status

---

## 🔧 How It Works Internally

### Cart Storage (LocalStorage via SharedPreferences)
```
App Start
    ↓
SharedPreferences initialized (in main.dart)
    ↓
CartService created
    ↓
Cart items loaded from disk (Key: "shopping_cart")
```

### Add to Cart Flow
```
Click Add to Cart
    ↓
Create CartItem object
    ↓
CartService.addToCart()
    ↓
Check if item exists
    → If exists: increase quantity
    → If new: add to list
    ↓
Save to SharedPreferences
    ↓
Show success notification
```

### Payment Flow
```
Click Proceed to Payment
    ↓
OrderService.createOrder()
    → Backend creates order
    → Returns orderId
    ↓
PaymentService.createPayment()
    → Backend generates VNPAY payment URL
    → Returns paymentUrl
    ↓
url_launcher opens payment URL
    ↓
Customer pays on VNPAY
    ↓
VNPAY redirects back with status
    ↓
PaymentResultPage shows status
    ↓
Cart automatically cleared
```

---

## 📊 API Integration

### Expected Backend Endpoints:

**Orders:**
- `POST /orders/create` - Create order
- `GET /orders/{orderId}` - Get order details  
- `GET /orders/user/orders` - Get user's orders
- `PATCH /orders/{orderId}/status` - Update status
- `POST /orders/{orderId}/cancel` - Cancel order

**Payments:**
- `POST /payments/create-payment` - Create VNPAY payment
- `GET /payments/check-status/{orderId}` - Check status

**Response Format** (example):
```json
{
  "status": true,
  "success": {
    "orderId": "16817234567890123456",
    "paymentUrl": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?...",
    "amount": 50.00
  }
}
```

---

## 🎨 UI Components

### Cart Page Features:
- ✅ Item display with images
- ✅ Quantity controls (+ / -)
- ✅ Price calculations
- ✅ Remove item button
- ✅ Clear cart option
- ✅ Checkout button
- ✅ Empty cart state

### Payment Result Page Features:
- ✅ Success/Failure/Pending states
- ✅ Order and transaction details
- ✅ Retry option for failed payments
- ✅ Navigation options

---

## 🧪 Testing Checklist

- [ ] Add item to cart
- [ ] Verify cart item count badge appears
- [ ] Open cart page
- [ ] Adjust quantity
- [ ] Remove item
- [ ] Clear cart
- [ ] Verify items persist after app restart
- [ ] Proceed to payment
- [ ] Complete VNPAY payment
- [ ] See payment result page
- [ ] Verify cart is cleared after payment

---

## 💡 Customization Tips

### Change Cart Colors:
In `cart_page.dart`, modify colors in `_buildCheckoutBar()`:
```dart
backgroundColor: Colors.black,  // Change this
```

### Add Discount/Tax:
Update `_getTotalPrice()` in `_CartPageState`:
```dart
double _getTotalPrice() {
  double subtotal = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double tax = subtotal * 0.1; // 10% tax
  return subtotal + tax;
}
```

### Custom Cart Icon:
In `dashboard.dart`, replace the icon:
```dart
Icon(Icons.shopping_bag_outlined, ...)  // Change to different icon
```

---

## ❌ Troubleshooting

| Issue | Solution |
|-------|----------|
| Cart items not saving | Verify SharedPreferences initialized in main.dart |
| Cart icon not showing count | Check CartService is initialized before use |
| Payment URL won't open | Ensure url_launcher dependency is added |
| API 401 errors | Check authentication token is valid |
| VNPAY page blank | Verify backend URL is correct and backend is running |
| Cart empty after app restart | SharedPreferences may be cleared; try clearing app cache |

---

## 📚 Additional Resources

- [SharedPreferences Documentation](https://pub.dev/packages/shared_preferences)
- [VNPAY Integration Guide](../VNPAY_FLUTTER_GUIDE.md)
- [Full Setup Documentation](CART_AND_PAYMENT_SETUP.md)

---

## 🎯 Next Enhancements (Optional)

1. **Order History Screen** - View past orders
2. **Favorites Feature** - Save favorite items
3. **Coupon/Promo Code** - Apply discounts
4. **Order Tracking** - Real-time order status
5. **Payment Methods** - Multiple payment options
6. **Reviews & Ratings** - Customer feedback
7. **Wishlist** - Save items for later
8. **Quantity Presets** - Common quantities (1x, 2x, 5x portions)

---

Generated: 2024
For questions or issues, refer to the full documentation in `CART_AND_PAYMENT_SETUP.md`
