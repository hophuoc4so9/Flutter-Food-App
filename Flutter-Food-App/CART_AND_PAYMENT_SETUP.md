# Shopping Cart & VNPay Payment Integration

## Overview
This implementation adds a complete shopping cart system to your Flutter Food App with persistent storage using SharedPreferences and VNPAY payment integration.

## What's Been Implemented

### 1. **Models** (`lib/models/`)
- **`cart_item.dart`** - CartItem model representing a food item in the cart
  - Properties: id, name, imageUrl, price, description, quantity
  - Methods: toJson(), fromJson(), totalPrice calculation
  
- **`order.dart`** - Order model for order management
  - Properties: orderId, items, totalAmount, status, createdAt, paymentId
  - Status tracking: PENDING, SUCCESS, FAILED, CANCELLED

### 2. **Services** (`lib/services/`)

#### **`cart_service.dart`** - Cart Management Service
Main methods:
- `getCartItems()` - Retrieve all items from cart
- `addToCart(CartItem)` - Add item or increase quantity if exists
- `removeFromCart(itemId)` - Remove item from cart
- `updateQuantity(itemId, quantity)` - Update item quantity
- `clearCart()` - Clear entire cart
- `getTotalPrice()` - Calculate total cart price
- `getTotalQuantity()` - Get total items count
- `getCartItemCount()` - Get number of unique items
- `isInCart(itemId)` - Check if item exists
- `getItemQuantity(itemId)` - Get quantity of specific item

**Storage**: Uses SharedPreferences with key `shopping_cart`

#### **`order_service.dart`** - Order Management Service
Main methods:
- `createOrder(items, description)` - Create order from cart items
- `getOrder(orderId)` - Fetch order details
- `getUserOrders()` - Get all user orders
- `updateOrderStatus(orderId, status)` - Update order status
- `cancelOrder(orderId)` - Cancel an order

**API Integration**: 
- Endpoint: `/orders/create`
- Returns: orderId, order details

#### **`payment_service.dart`** - Payment Management Service
Main methods:
- `createPayment(amount, description)` - Create VNPAY payment request
- `checkPaymentStatus(orderId)` - Check payment status
- `getUserPayments(status, limit, skip)` - Retrieve payment history

**API Integration**:
- Create Payment: `/payments/create-payment` (POST)
- Check Status: `/payments/check-status/{orderId}` (GET)
- VNPAY Callbacks: `/payments/vnpay-return`, `/payments/vnpay-ipn`

### 3. **Screens** (`lib/screens/`)

#### **`cart_page.dart`** - Shopping Cart Screen
Features:
- Display all cart items with images
- Quantity adjustment controls (+ / -)
- Item removal functionality
- Clear entire cart
- Real-time total price calculation
- Responsive layout with empty state
- Integration with payment flow

**Checkout Flow**:
1. Create order from cart items
2. Initiate VNPAY payment
3. Clear cart after payment initiation
4. Show success/failure status

#### **`payment_result_page.dart`** - Payment Result Screen
Features:
- Display payment status (Success/Failed/Pending)
- Show order and transaction details
- Transaction number, bank code, payment date
- Retry functionality for failed payments
- Navigation options

### 4. **Updated Files**

#### **`food_detail_page.dart`**
- Added CartService integration
- "Add to Cart" button now saves items to SharedPreferences
- Quantity selector
- Toast notification on successful add
- Price parsing utilities

#### **`dashboard.dart`**
- Shopping cart icon now navigates to CartPage
- Dynamic cart item count badge (red)
- Cart count updates when returning from cart page
- Integrated with CartService

---

## Configuration Required

### 1. **Update API Base URL**
In `dashboard.dart`, update the baseUrl in CartPage navigation:
```dart
baseUrl: 'http://your-backend-url:3000'  // Change this
```

Similarly in any place where CartPage, OrderService, or PaymentService is instantiated.

### 2. **Dependencies in pubspec.yaml**
Ensure these are already added (they appear to be):
```yaml
shared_preferences:
http:
url_launcher:
```

### 3. **Backend Integration**
The implementation expects these API endpoints:

**Orders API**:
- `POST /orders/create` - Create order
- `GET /orders/{orderId}` - Get order details
- `GET /orders/user/orders` - Get user's orders
- `PATCH /orders/{orderId}/status` - Update order status
- `POST /orders/{orderId}/cancel` - Cancel order

**Payments API**:
- `POST /payments/create-payment` - Create VNPAY payment
- `GET /payments/check-status/{orderId}` - Check payment status

**VNPAY Return/IPN**:
- `GET /payments/vnpay-return` - Return URL callback
- `GET /payments/vnpay-ipn` - IPN callback (server-to-server)

---

## Usage Flow

### 1. **Customer adds item to cart**
```
Food Detail Page → Click "Add to Cart" → CartService saves to SharedPreferences
```

### 2. **View Shopping Cart**
```
Dashboard → Click Cart Icon → CartPage displays all items
```

### 3. **Checkout Process**
```
CartPage → Click "Proceed to Payment" → 
  1. Create Order (OrderService)
  2. Create Payment (PaymentService)
  3. Launch VNPAY Payment URL (url_launcher)
  4. Customer completes payment on VNPAY
  5. Redirect to Payment Result Page
```

### 4. **Check Payment Status**
```
Payment Result Page → Shows order details and payment status
```

---

## Data Storage (SharedPreferences)

### Cart Storage
```json
[
  {
    "id": "food_id",
    "name": "Food Name",
    "imageUrl": "https://...",
    "price": 12.99,
    "description": "...",
    "quantity": 2
  }
]
```

Key: `shopping_cart`

---

## Features Summary

✅ **Persistent Cart** - Cart data saved locally with SharedPreferences
✅ **Cart Management** - Add, remove, update quantities
✅ **Order Creation** - Create orders from cart items
✅ **VNPAY Integration** - Full payment flow with VNPAY
✅ **Payment Status** - Track payment status
✅ **UI Components** - Professional cart and payment pages
✅ **Error Handling** - Comprehensive error messages
✅ **Loading States** - Visual feedback during operations
✅ **Responsive Design** - Works on different screen sizes

---

## Next Steps

1. **Configure Backend URL** - Update API base URLs in all service implementations
2. **Test Cart Functionality** - Add items and verify they persist
3. **Test Payment Flow** - Complete end-to-end VNPAY payment
4. **Add Order History** - Create a screen to show previous orders
5. **Add Notifications** - Show payment notifications using local notifications
6. **Handle Deep Links** - Handle VNPAY redirect in app

---

## Troubleshooting

### Cart items not persisting?
- Check SharedPreferences is initialized in main()
- Verify CartService is properly initialized before use

### Payment URL not opening?
- Ensure `url_launcher` package is properly added
- Check if the URL is valid from the backend

### API errors?
- Verify backend is running
- Check API base URL configuration
- Check authentication token is valid

### VNPAY sandbox testing?
- Use test credentials from VNPAY documentation
- Test cards: 4111111111111111 (Visa), expiry: 12/30, OTP: 123456
